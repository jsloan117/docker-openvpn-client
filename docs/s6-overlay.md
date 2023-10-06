---
hide:
  - navigation
  # - toc
---

s6-overlay is the init system installed in this image and provides [s6](https://skarnet.org/software/s6/).
It contains a small suite of programs for UNIX designed to allow process supervision.

The tag v3.0.0 is utilizing version 2.x of s6. Since then, v3 has been released and is a complete rewrite.

I've taken partial snippets of the s6-overlay [readme](https://github.com/just-containers/s6-overlay/blob/master/README.md) that I thought were useful to understand quickly.
This page is not meant to replace it nor the s6 [docs](https://skarnet.org/software); they are very detailed.

## init stages

---

This section briefly explains how the [init stages](https://skarnet.org/software/s6/s6-svscan-1.html) work for s6-overlay. If you need more details, check out s6-overlay's [readme](https://github.com/just-containers/s6-overlay/blob/master/README.md#init-stages).

1. **stage 1**: s6-overlay black magic and container setup details.
2. **stage 2**: This is where most of the end-user-provided files are meant to be executed:
    1. (legacy) - Sequentially execute one-shot initialization scripts in `/etc/cont-init.d`.
    2. s6-rc starts services in the `user` bundle in an order defined by dependencies. If the services depend on `base`, they are guaranteed to start at this point and not earlier. If they do not, they might start earlier, which may cause race conditions - so it's always recommended to make them depend on `base`.
    3. (legacy) - Longrun services in `/etc/services.d` are started.
3. **stage 3**: This is the shutdown stage. When the container is supposed to exit, it will:
    1. (legacy) - Longrun services in `/etc/services.d` are stopped.
    2. All s6-rc services are stopped in an order defined by dependencies.
    3. (legacy) - Sequentially execute one-shot finalization scripts in `/etc/cont-finish.d`.

## s6-rc service manager

---

I will outline the core directory structure of the new [s6-rc](https://www.skarnet.org/software/s6-rc/overview.html) service format since it's pretty different than v2.

For more details, check out [s6-rc-compile](https://skarnet.org/software/s6-rc/s6-rc-compile.html#source).
For examples of s6-rc services, you can check out this image's repo or linuxserver's images.

This image utilizes only a few files you can use for s6 services. I won't go into detail about them; refer to the link above.

!!! note
      Your first service should depend on the `base` bundle. It tells [s6-rc](https://www.skarnet.org/software/s6-rc/) to only start `my_service_name` when all the base services are ready: it prevents race conditions.

       ```bash
       /etc/s6-overlay/s6-rc.d/my_service_name/dependencies.d
       /etc/s6-overlay/s6-rc.d/my_service_name/dependencies.d/base
       ```

### service directory

A [service directory](https://skarnet.org/software/s6/servicedir.html) contains all the information related to a service. e.g., a long-running process maintained and supervised by [s6-supervise](https://skarnet.org/software/s6/s6-supervise.html).

You now create services under `/etc/s6-overlay/s6-rc.d` instead of `/etc/services.d`.

??? example "service directory"

    ```bash
    /etc/s6-overlay/s6-rc.d/my_service_name
    ```

### service type

Create a file named `type` that contains one of the following `oneshot`, `longrun`, or `bundle`. This file declares the type of service you want.
A `bundle` is a collection of services described under a single name.

??? example "service type"

    ```bash
    cat /etc/s6-overlay/s6-rc.d/my_service_name/type
    longrun
    ```

Create a `run` file for `longrun` or `up` for `oneshot` services.
This file should contain your code to start the `my_service_name` service.

??? example "longrun service"

    ```bash
    cat /etc/s6-overlay/s6-rc.d/my_service_name/run
    #!/command/with-contenv bash
    my_service_name_daemon
    ```

??? example "oneshot service"

    ```bash
    cat /etc/s6-overlay/s6-rc.d/oneshot_service_name/up
    my_service_name_daemon
    ```

!!! note
      All shell-like files should be executable, any `run` or `*.sh` files. Oneshot files (up/down) do not need to be executable.

***Optionally*** create a `finish` file for `longrun` or `down` for `oneshot` services.

Create an empty file named after your service in the `user` bundle directory. This file is how s6-rc will start your service.

??? example "user bundle"

    ```bash
    /etc/s6-overlay/s6-rc.d/user/contents.d/my_service_name
    ```

### dependencies

Your `oneshot` or `longrun` service(s) can depend on other services (including bundles); however, a bundle cannot have dependencies.

If `my_service_name` depends on `some_other_service` running before it, create a `dependencies.d` directory.

Then create an empty file named after that depended upon service in the `dependencies.d` directory.

??? example "my_service_name depends on some_other_service"

    ```bash
    /etc/s6-overlay/s6-rc.d/my_service_name/dependencies.d/some_other_service
    ```

## additional documentation and information

---

Here are a few links containing much more information than I care to write :smile:.

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

