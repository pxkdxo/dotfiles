--- Native MCP server: task orchestrator with sub-agent delegation
--- Decomposes complex tasks into dependency-ordered sub-tasks and tracks
--- their execution state so the LLM can work through them systematically.

local plans = {}
local plan_seq = 0

--- Status icons used in human-readable plan summaries.
local status_icon = {
  pending = "○",
  in_progress = "◑",
  completed = "●",
  failed = "✗",
}

--- Count how many sub-tasks in a plan have reached a given status.
local function count_status(subtasks, status)
  local n = 0
  for _, st in ipairs(subtasks) do
    if st.status == status then
      n = n + 1
    end
  end
  return n
end

--- Return true when every dependency of `subtask` is completed.
local function deps_met(plan, subtask)
  for _, dep_id in ipairs(subtask.depends_on) do
    local dep = plan.subtasks[dep_id]
    if not dep or dep.status ~= "completed" then
      return false
    end
  end
  return true
end

--- Format a plan as a human-readable status report.
local function format_plan(plan)
  local completed = count_status(plan.subtasks, "completed")
  local lines = {
    ("Plan: %s  (id: %s)"):format(plan.title, plan.id),
    ("Status: %s | Created: %s | Progress: %d/%d"):format(
      plan.status,
      plan.created_at,
      completed,
      #plan.subtasks
    ),
    "",
    "Sub-tasks:",
  }
  for _, st in ipairs(plan.subtasks) do
    local icon = status_icon[st.status] or "?"
    lines[#lines + 1] = ("  %s [%d] %s  (%s)"):format(icon, st.id, st.title, st.status)
    if st.result then
      lines[#lines + 1] = ("       Result: %s"):format(st.result)
    end
    if #st.depends_on > 0 then
      local ids = {}
      for _, d in ipairs(st.depends_on) do
        ids[#ids + 1] = tostring(d)
      end
      lines[#lines + 1] = ("       Depends on: %s"):format(table.concat(ids, ", "))
    end
  end
  return table.concat(lines, "\n")
end

---------------------------------------------------------------------------

return {
  name = "orchestrator",
  displayName = "Task Orchestrator",
  capabilities = {
    tools = {
      -- 1. create_plan -------------------------------------------------------
      {
        name = "create_plan",
        description = "Decompose a complex task into ordered sub-tasks with "
          .. "optional dependency edges.  Returns a plan ID used by all "
          .. "subsequent orchestration tools.",
        inputSchema = {
          type = "object",
          properties = {
            title = {
              type = "string",
              description = "Short title for the overall task",
            },
            subtasks = {
              type = "array",
              description = "Ordered list of sub-tasks",
              items = {
                type = "object",
                properties = {
                  title = { type = "string", description = "Sub-task title" },
                  description = {
                    type = "string",
                    description = "Detailed instructions for this sub-task",
                  },
                  tools = {
                    type = "array",
                    items = { type = "string" },
                    description = "MCP tool names this sub-task should use",
                  },
                  depends_on = {
                    type = "array",
                    items = { type = "integer" },
                    description = "IDs (1-based) of sub-tasks that must complete first",
                  },
                },
                required = { "title", "description" },
              },
            },
          },
          required = { "title", "subtasks" },
        },
        handler = function(req, res)
          plan_seq = plan_seq + 1
          local id = tostring(plan_seq)

          local subtasks = {}
          for i, st in ipairs(req.params.subtasks) do
            subtasks[i] = {
              id = i,
              title = st.title,
              description = st.description,
              tools = st.tools or {},
              depends_on = st.depends_on or {},
              status = "pending",
              result = nil,
            }
          end

          plans[id] = {
            id = id,
            title = req.params.title,
            subtasks = subtasks,
            status = "active",
            created_at = os.date("%Y-%m-%dT%H:%M:%S"),
          }

          return res
            :text(("Plan created — id: %s, title: '%s', sub-tasks: %d\n\n"):format(id, req.params.title, #subtasks))
            :text("Use `get_next_subtask` to begin execution.")
            :send()
        end,
      },

      -- 2. get_next_subtask --------------------------------------------------
      {
        name = "get_next_subtask",
        description = "Return the first pending sub-task whose dependencies "
          .. "are all completed.  Automatically marks it in-progress.",
        inputSchema = {
          type = "object",
          properties = {
            plan_id = { type = "string", description = "Plan ID" },
          },
          required = { "plan_id" },
        },
        handler = function(req, res)
          local plan = plans[req.params.plan_id]
          if not plan then
            return res:error("Plan not found: " .. req.params.plan_id)
          end

          for _, st in ipairs(plan.subtasks) do
            if st.status == "pending" and deps_met(plan, st) then
              st.status = "in_progress"
              local parts = {
                ("## Sub-task %d: %s\n"):format(st.id, st.title),
                st.description,
              }
              if #st.tools > 0 then
                parts[#parts + 1] = "\n\nSuggested tools: " .. table.concat(st.tools, ", ")
              end
              return res:text(table.concat(parts)):send()
            end
          end

          if count_status(plan.subtasks, "completed") == #plan.subtasks then
            plan.status = "completed"
            return res:text("All sub-tasks completed. Plan '" .. plan.title .. "' is done."):send()
          end

          return res:text("No runnable sub-tasks — remaining tasks are blocked by unfinished dependencies."):send()
        end,
      },

      -- 3. complete_subtask --------------------------------------------------
      {
        name = "complete_subtask",
        description = "Record a sub-task as completed with a result summary.",
        inputSchema = {
          type = "object",
          properties = {
            plan_id = { type = "string", description = "Plan ID" },
            subtask_id = { type = "integer", description = "Sub-task ID (1-based)" },
            result = { type = "string", description = "Summary of what was accomplished" },
          },
          required = { "plan_id", "subtask_id", "result" },
        },
        handler = function(req, res)
          local plan = plans[req.params.plan_id]
          if not plan then
            return res:error("Plan not found: " .. req.params.plan_id)
          end
          local st = plan.subtasks[req.params.subtask_id]
          if not st then
            return res:error("Sub-task not found: " .. tostring(req.params.subtask_id))
          end

          st.status = "completed"
          st.result = req.params.result
          st.completed_at = os.date("%Y-%m-%dT%H:%M:%S")

          local done = count_status(plan.subtasks, "completed")
          if done == #plan.subtasks then
            plan.status = "completed"
          end

          return res:text(("Sub-task %d '%s' completed.  Progress: %d/%d"):format(
            st.id, st.title, done, #plan.subtasks
          )):send()
        end,
      },

      -- 4. fail_subtask ------------------------------------------------------
      {
        name = "fail_subtask",
        description = "Mark a sub-task as failed and identify any downstream "
          .. "tasks that are now blocked.",
        inputSchema = {
          type = "object",
          properties = {
            plan_id = { type = "string", description = "Plan ID" },
            subtask_id = { type = "integer", description = "Sub-task ID (1-based)" },
            reason = { type = "string", description = "Reason for failure" },
          },
          required = { "plan_id", "subtask_id", "reason" },
        },
        handler = function(req, res)
          local plan = plans[req.params.plan_id]
          if not plan then
            return res:error("Plan not found: " .. req.params.plan_id)
          end
          local st = plan.subtasks[req.params.subtask_id]
          if not st then
            return res:error("Sub-task not found: " .. tostring(req.params.subtask_id))
          end

          st.status = "failed"
          st.result = "FAILED: " .. req.params.reason

          local blocked = {}
          for _, other in ipairs(plan.subtasks) do
            for _, dep in ipairs(other.depends_on) do
              if dep == req.params.subtask_id and other.status == "pending" then
                blocked[#blocked + 1] = ("[%d] %s"):format(other.id, other.title)
              end
            end
          end

          local msg = ("Sub-task %d '%s' failed: %s"):format(st.id, st.title, req.params.reason)
          if #blocked > 0 then
            msg = msg .. "\nBlocked downstream tasks:\n  " .. table.concat(blocked, "\n  ")
          end
          return res:text(msg):send()
        end,
      },

      -- 5. get_plan_status ---------------------------------------------------
      {
        name = "get_plan_status",
        description = "Show the full status of a plan including every sub-task.",
        inputSchema = {
          type = "object",
          properties = {
            plan_id = { type = "string", description = "Plan ID" },
          },
          required = { "plan_id" },
        },
        handler = function(req, res)
          local plan = plans[req.params.plan_id]
          if not plan then
            return res:error("Plan not found: " .. req.params.plan_id)
          end
          return res:text(format_plan(plan)):send()
        end,
      },

      -- 6. list_plans --------------------------------------------------------
      {
        name = "list_plans",
        description = "List all orchestration plans (active and completed).",
        inputSchema = { type = "object", properties = {} },
        handler = function(_, res)
          if next(plans) == nil then
            return res:text("No plans created yet."):send()
          end

          local lines = { "Plans:" }
          for _, plan in pairs(plans) do
            local done = count_status(plan.subtasks, "completed")
            lines[#lines + 1] = ("  [%s] %s — %s  (%d/%d done)"):format(
              plan.id, plan.title, plan.status, done, #plan.subtasks
            )
          end
          return res:text(table.concat(lines, "\n")):send()
        end,
      },
    },

    resources = {
      {
        name = "active_plans",
        uri = "orchestrator://plans",
        description = "All orchestration plans and their current state",
        handler = function(_, res)
          if next(plans) == nil then
            return res:text("No plans."):send()
          end
          local summaries = {}
          for _, plan in pairs(plans) do
            summaries[#summaries + 1] = format_plan(plan)
          end
          return res:text(table.concat(summaries, "\n\n---\n\n")):send()
        end,
      },
    },

    resourceTemplates = {
      {
        name = "plan_detail",
        uriTemplate = "orchestrator://plans/{plan_id}",
        description = "Detailed view of a single orchestration plan",
        handler = function(req, res)
          local plan = plans[req.params.plan_id]
          if not plan then
            return res:error("Plan not found: " .. req.params.plan_id)
          end
          return res:text(format_plan(plan)):send()
        end,
      },
    },

    prompts = {
      {
        name = "orchestrate",
        description = "Break a complex task into sub-tasks and execute them "
          .. "in dependency order using available MCP tools.",
        arguments = {
          {
            name = "task",
            description = "The complex task to decompose and orchestrate",
            required = true,
          },
        },
        handler = function(req, res)
          return res
            :user()
            :text(("I need you to orchestrate the following complex task:\n\n"
              .. "**Task:** %s\n\n"
              .. "Please follow this workflow:\n"
              .. "1. Analyze the task and identify logical sub-tasks with dependencies.\n"
              .. "2. Call `create_plan` with all sub-tasks.\n"
              .. "3. Loop: call `get_next_subtask`, execute it using the appropriate "
              .. "MCP tools, then call `complete_subtask` (or `fail_subtask`).\n"
              .. "4. Repeat step 3 until there are no more sub-tasks.\n"
              .. "5. Call `get_plan_status` to review the final outcome."
            ):format(req.params.task))
            :llm()
            :text("I'll orchestrate this task step by step. Let me start by "
              .. "analyzing the work and creating a structured plan with "
              .. "dependency-ordered sub-tasks.")
            :send()
        end,
      },
    },
  },
}
