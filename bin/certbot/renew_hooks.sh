#!/bin/bash

# Used with the certbot renew --pre-hook and --post-hook features.

pre_hook=false
post_hook=false

usage()
{
    echo "usage: renew_hooks --pre|--post"
    exit 1
}

while [ "$1" != "" ]; do
case $1 in
  --pre ) shift
          pre_hook=true
    ;;
  --post ) shift
           post_hook=true
    ;;
  * ) usage
esac
done

if [[ $pre_hook = true &&  $post_hook = true ]] || [[ $pre_hook = false &&  $post_hook = false ]]; then
    usage
fi

if [[ $pre_hook = true ]]; then
  echo "Pre-renewal hook"
fi
if [[ $post_hook = true  ]]; then
  echo "Post renewal hook"
fi
