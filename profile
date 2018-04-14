## ~/.profile : login shell init file

## Initialize terminal
tput init

## Set file mode creation mask
umask 027

## Append default command paths
for _ in "${HOME}/bin" "${HOME}/.local/bin"; do
  case ":${PATH}:" in
    *:"$_":*)
      ;;
    *)
      PATH="${PATH:+"${PATH}:"}$_"
  esac
done
export PATH
