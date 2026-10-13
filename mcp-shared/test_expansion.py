import unittest
from launch_backend import expand,prepare
class ExpansionTests(unittest.TestCase):
    def test_nested_and_literal_secret(self):
        self.assertEqual(expand({"env":{"X":"${TOKEN}"}},{"TOKEN":"a$()${OTHER}"}),
                         {"env":{"X":"a$()${OTHER}"}})
    def test_missing_and_empty_credential_fail(self):
        with self.assertRaisesRegex(ValueError,"TOKEN"): expand("${TOKEN}",{})
        with self.assertRaisesRegex(ValueError,"KEY"):
            prepare({"command":"example","env":{"KEY":"${TOKEN}"}},{"TOKEN":""})
    def test_standard_template(self):
        self.assertEqual(expand("$HOST/${PATH}/$$",{"HOST":"example","PATH":"api"}),"example/api/$")
    def test_region_in_arguments(self):
        spec,env=prepare({"command":"example","args":["--region","${AWS_REGION}"]},{"AWS_REGION":"us-west-2"})
        self.assertEqual(spec["args"],["--region","us-west-2"])
        self.assertNotIn("AWS_REGION",env)
    def test_literal_empty_setting(self):
        self.assertEqual(prepare({"command":"example","env":{"OPTION":""}}, {})[1]["OPTION"],"")
    def test_no_shell_defaults(self):
        with self.assertRaises(ValueError): expand("${NAME:-default}",{})
if __name__=="__main__": unittest.main()
