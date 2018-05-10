##
## ~/.bashrc.d/20-tilib : terminfo function library
##


## Display capability longnames next to corresponding terminfo names
function ti::namestab() {
  xargs -n 2 printf '%-24s%-8s%s\n' \
    < <(paste \
      <(tail -n +3 \
        <(sed -E 's@^\s+([^##=,]+).+$@\1@' \
          <(infocmp -1 -q -s i -t -L))) \
      <(tail -n +2 \
        <(sed -E 's@^\s+([^##=,]+).+$@\1@' \
          <(infocmp -1 -q -s i -t -I))))
}
