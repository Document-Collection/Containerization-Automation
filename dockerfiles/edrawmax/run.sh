docker run \
     --rm -it \
      -v /tmp/.X11-unix:/tmp/.X11-unix \
      -e DISPLAY=unix$DISPLAY  \
      --privileged \
      -e XMODIFIERS="@im=fcitx" \
      -e QT_IM_MODULE="fcitx" \
      -e GTK_IM_MODULE="fcitx" \
      -e GID=`id -g` \
      -e UID=`id -u` \
      --name edrawmax \
      --gpus all \
      -d \
      zjzstu/edrawmax:latest \
      edrawmax