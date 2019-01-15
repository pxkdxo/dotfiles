#
## collection of text decoding functions
#

## Decode a base64-encoded string 
decode::base64() {
  base64 --decode <<<"$1" && echo
}




# vim:ft=sh:tw=80

