# Lab 4. Configuring your kubernetes applications 

## 1. Configuring your application using environment variables.

In 2011 the developers at [Heroku](https://www.heroku.com/) presented a methodology for building software-as-a-service application [The Twelve-Factor App](https://12factor.net/) methodology. The 3rd of these twelve factors is to store config in the environment you can read more about this [here](https://12factor.net/config). Over the following exercises we will be looking at different ways to do this with kubernetes.


Let's start by creating a namespace for all the work we will be doing this lab, and setting it as the default namespace.

```powershell
kubectl create namespace lab4 
kubectl config set-context --current --namespace=lab4
```
Then let's create an application to display the current configuration.

```powershell
dotnet new razor -o Lab4
```

Open the `Index.cshtml.cs` file and replace the content with the following

```C#
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace Lab4.Pages
{
    public class IndexModel : PageModel
    {
        private readonly ILogger<IndexModel> logger;
        private readonly IConfiguration config;

        public Dictionary<string, string> Values = new Dictionary<string, string>();

        public IndexModel(ILogger<IndexModel> logger, IConfiguration config)
        {
            this.logger = logger;
            this.config = config;
        }

        public void OnGet()
        {
            foreach (var value in config.AsEnumerable())
            {
                Values.Add(value.Key, value.Value);
            }
        }
    }
}
```
Open the `Index.cshtml` file and replace the content with the following.

```cshtml
@page
@model IndexModel
@{
    ViewData["Title"] = "Home page";
}

<div class="text-center">
    <h1 class="display-4">Configuration</h1>
</div>
<dl>
    @foreach (var item in Model.Values)
    {
          <dt>@item.Key</dt>
          <dd>@item.Value</dd>
    }
</dl>
```

Next lets add a `Dockerfile` with the following content.

```text
#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src
COPY ["Lab4/Lab4.csproj", "Lab4/"]
RUN dotnet restore "Lab4/Lab4.csproj"
COPY . .
WORKDIR "/src/Lab4"
RUN dotnet build "Lab4.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Lab4.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Lab4.dll"]
```

Cool now lets build run and check the application.

```powershell
az acr build --registry $ACR_NAME --image configwebapp:v1 .
docker run --rm -it -p 8082:80 "$($ACR_NAME).azurecr.io/configwebapp:v1" 
```

We can now run our application in kubernetes lets prepare some files so we can create our resources using declarative object configuration. 

Create a folder named resources and add the following files.

deployment.yaml:

```text
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: configapp
  name: configapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: configapp
  strategy: {}
  template:
    metadata:
      labels:
        app: configapp
    spec:
      containers:
      - image: arcbc5524.azurecr.io/configwebapp:v1
        name: configwebapp

```

service.yaml

```text
apiVersion: v1
kind: Service
metadata:
  labels:
    app: configapp
  name: configapp
spec:
  ports:
  - port: 80
  selector:
    app: configapp
  type: LoadBalancer
```

We can now deploy and expose the application.

```powershell
kubectl apply -f resources/
kubectl get service configapp -w
```

One we have an assigned EXTERNAL-IP you should be able to visit the application and see the already configured values.










## 2. Configuring sensitive information using `Secrets`

## 3. Preventing resource starvation with resource request and limits

From the [docs](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-types):
> **Note:** If a Container specifies its own memory limit, but does not specify a memory request, Kubernetes automatically assigns a memory request that matches the limit. Similarly, if a Container specifies its own CPU limit, but does not specify a CPU request, Kubernetes automatically assigns a CPU request that matches the limit.

## 4. Configuring Liveness, Readiness, Startup probes and pod lifecycle.

## 5. Using managed pod identity to access key vault secrets

## 6. Managing pod placement

## 7. Configuring apiserver access with Pod Service accounts

[:arrow_backward: previous](../lab3-workloads/LAB.md)  [next :arrow_forward:](../lab5-networking/LAB.md)