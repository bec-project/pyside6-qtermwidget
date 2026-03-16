## PySide 6 Bindings for QTermWidget

- to run cibuildwheel locally, set the CIBUILDWHEEL_WORKSPACE environment variable to the working directory and
  then install Qt there using the commands from the CI file
- it can be helpful to run a local cache such as squid for DNF packages
  - use `environment = { "http_proxy" = "host.containers.internal:3128" }`
  - set up squid to have a big object size and allow connections from the container
