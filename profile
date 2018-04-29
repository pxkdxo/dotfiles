## ~/.profile : login shell init file

## Initialize terminal
command -p tput init

## Set file mode mask
command -p umask 027

## Append my path
case :${PATH}: in
  *:"${HOME}"/.local/bin:*)
    ;;
  *)
    PATH=${PATH:+${PATH}:}${HOME}/.local/bin
    ;;
esac
command -p export PATH

## Load additional config
for _ in "${HOME}"/.profile/?*; do
  test -f "$_" && test -r "$_" && . "$_"
done
