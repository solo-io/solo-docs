---
title: Configuration
weight: 2
---

Squash can be used without any configuration. However, for convenience or to take advantage of certain IDE and debuggur features, you can configure various parameters.


### Source code mapping

Source code mapping tells your debugger how to translate filepaths from your local environment to filepaths on the process that you are trying to debug. If you compiled and deployed the process that you are debugging, source path mapping should not be required. However, if you are debugging a process that was compiled by a teammate or an automated release process, you need to tell your debugger how a breakpoint set on your local source file should be applied to the process you are debugging.


For example, let's say I am trying to debug a service that my teammate Yuval compiled and deployed.
 - The service is hosted in our code repo at `github.com/solo-io/squash/contrib/example/service1`.
 - We want to debug a `handler` function in `github.com/solo-io/squash/contrib/example/service1/main.go`.
 - When Yuval clones the source to his local environment, he puts it in `/home/yuval/go/src`.
 - The full path to the `main.go` file is `/home/yuval/go/src/github.com/solo-io/squash/contrib/example/service1/main.go`
   - When Yuval compiles this service (with debug flags enabled) the full path to our function will be `/home/yuval/go/src/github.com/solo-io/squash/contrib/example/service1/main.go:handler`
 - When I want to debug this service I first clone the source code.
 - Now I have access to the code in `/Users/mitch/go/src/github.com/solo-io/squash/contrib/example/service1/main.go`
 - I want to open a breakpoint on the `handler` function in `main.go`. To do so, I select `/Users/mitch/go/src/github.com/solo-io/squash/contrib/example/service1/main.go:handler`.
 - We need to tell the debugger how to map my break point specification to the equivalent source path on the target process.
```
# Note the similarity between these two paths:
/home/yuval/go/src/github.com/solo-io/squash/contrib/example/service1/main.go
/Users/mitch/go/src/github.com/solo-io/squash/contrib/example/service1/main.go

# These paths are identical from this point on:
/home/yuval/
/Users/mitch/

# They both share this path:
go/src/github.com/solo-io/squash/contrib/example/service1/main.go
```


Depending on the IDE and debugger you are using, you can specify source code maping one of these two ways:
 - Specify the "from" and "to" paths [this is how `dlv` path substitution in `squashctl` works]
   - In this case, you can choose the minimum unique path identifiers
   - For example:
```
# This is the minimum path specification required:
From: /Users/mitch/
To:   /home/yuval/
# This will also work:
From: /Users/mitch/go/src/github.com/solo-io/squash/
To: /home/yuval/go/src/github.com/solo-io/squash/
```
 - Infer the "From" path from the "workspace" directory that you have opened [this is how path substitution works in `vscode`]
   - In this case, you must specify a substitution that replaces your "workspace" path with the equivalent target path.
   - For example:
```
# workspace: /Users/mitch/go/src/github.com/solo-io/squash/contrib/example/service1/
 substitute: /home/yuval/go/src/github.com/solo-io/squash/contrib/example/service1/
# workspace: /Users/mitch/go/src/github.com/solo-io/squash/
 substitute: /home/yuval/go/src/github.com/solo-io/squash/
# workspace: /Users/mitch/
 substitute: /home/yuval/
```
