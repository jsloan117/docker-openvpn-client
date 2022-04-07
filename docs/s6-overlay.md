---
hide:
  - navigation
  # - toc
---

s6-overlay is the init system installed in the image.
Just like a regular init-system it runs a PID 1, and all other processes after after that.

The tag v3.0.0 is utilizing version 2.x of s6. Since then v3 has been released and it's a complete rewrite.

I've taken partial snippets of the s6-overlay [readme](https://github.com/just-containers/s6-overlay/blob/master/README.md) that I thought were useful to understand quickly.
This page is not meant to replace it (readme) nor the s6 [docs](https://skarnet.org/software) they are very detailed.

## Init stages

---

This section briefly explains how the init stages work for s6-overlay. If you need more details check out s6-overlay's [readme](https://github.com/just-containers/s6-overlay/blob/master/README.md#init-stages).

1. **stage 1**: s6-overlay black magic and container setup details.
2. **stage 2**: This is where most of the end-user provided files are meant to be executed:
    1. (legacy) - Sequentially execute one-shot initialization scripts in `/etc/cont-init.d`.
    2. Services in the `user` bundle are started by s6-rc, in an order defined by dependencies.
    3. (legacy) - Longrun services in `/etc/services.d` are started.
3. **stage 3**: This is the shutdown stage. When the container is supposed to exit, it will:
    1. (legacy) - Longrun services in `/etc/services.d` are stopped.
    2. All s6-rc services are stopped, in an order defined by dependencies.
    3. (legacy) - Sequentially execute one-shot finalization scripts in `/etc/cont-finish.d`.

## s6-rc services

---

I will outline the core directory structure of the new `s6-rc` service format since its quite different than v2.

For more details check out [s6-rc-compile](https://skarnet.org/software/s6-rc/s6-rc-compile.html#source).
You can always check out this image's repo and see how I created them. Or look at linuxserver's images, that is how I started.

This image doesn't use many of the files you can use for s6 services, nor will I go into detail on them. Again refer to the link above.

Services are now created under `/etc/s6-overlay/s6-rc.d` instead of `/etc/services.d`.

??? example "my_service_name service directory"

    ```bash
    /etc/s6-overlay/s6-rc.d/my_service_name
    ```

Create a file named `type`, that contains only `oneshot`, `longrun` or `bundle`. This file declares the type of service you want.

??? example "service type"

    ```bash
    cat /etc/s6-overlay/s6-rc.d/my_service_name/type
    longrun
    ```

Create a file named `run` for `longrun` services or a file named `up` for `oneshot` services.
This should contain your code to run the `my_service_name` service.

??? example "service run script"

    ```bash
    cat /etc/s6-overlay/s6-rc.d/my_service_name/run
    #!/command/execlineb -P
    my_service_name_daemon
    ```

***Optionally*** create a file named `finish` for `longrun` services or a file named `down` for `oneshot` services.

Create a empty file named after your service, in the `user` bundle directory. This is how your service will be started.

??? example "user bundle"

    ```bash
    /etc/s6-overlay/s6-rc.d/user/contents.d/my_service_name
    ```

If `my_service_name` depends on `some_other_service` running before it, create a `dependencies.d` directory.

Then create a empty file named after that depended upon service in the `dependencies.d` directory.

??? example "dependencies"

    ```bash
    /etc/s6-overlay/s6-rc.d/my_service_name/dependencies.d
    /etc/s6-overlay/s6-rc.d/my_service_name/dependencies.d/some_other_service
    ```

## Additional documentation and information

---

Here are a few links that contain a lot more information then I care to write :smile:.

If you need to set an environment variable in `some_service` and use it in `some_other_service`, you may need to add it to s6's container_environment directory.

??? example "s6 container environment"

    ```bash
    printf '%s' "${variable_name}" > /run/s6/container_environment/variable_name
    ```

- [s6-overlay readme](https://github.com/just-containers/s6-overlay/blob/master/README.md)
- [move-to-v3](https://github.com/just-containers/s6-overlay/blob/master/MOVING-TO-V3.md)
- [s6-rc-compile](https://skarnet.org/software/s6-rc/s6-rc-compile.html#source)
- [servicedir](https://skarnet.org/software/s6/servicedir.html)
- [execlineb](https://skarnet.org/software/execline/execlineb.html)
- [s6-setuidgid](https://skarnet.org/software/s6/s6-setuidgid.html)

