# Lab 3. Running your applications in kubernetes

### In this lab we will look at the various ways we can run workloads in kubernetes

## 1. Creating and running a pod in kubernetes

Lets start by creating a namespace for all the work we will be doing this lab, and setting it as the default namespace.

```powershell
kubectl create namespace lab3 
kubectl config set-context --current --namespace=lab3
```

Now lets create a new dotnet 5 web application, you can follow along with the steps here or you can use visual studio and addding docker support.

```powershell
mkdir lab3
cd lab3
dotnet new web -o SimpleWebApp
```

Optionally change the `Startup.cs` file and edit the following line to something fun or original.

```C#
endpoints.MapGet("/", async context =>
{
    await context.Response.WriteAsync("Hello World!");
});
```

Run the application to make sure it is working as expected.

```powershell
cd SimpleWebApp
dotnet run
```

Add a new Dockerfile to the `lab3` directory and copy the following text into that file.

```Dockerfile
#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src
COPY ["SimpleWebApp/SimpleWebApp.csproj", "SimpleWebApp/"]
RUN dotnet restore "SimpleWebApp/SimpleWebApp.csproj"
COPY . .
WORKDIR "/src/SimpleWebApp"
RUN dotnet build "SimpleWebApp.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "SimpleWebApp.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "SimpleWebApp.dll"]
```

When we set up our environment in [lab1](../lab1-environment-setup/LAB.md) we also created a [Azure Container Registry](https://docs.microsoft.com/en-us/azure/container-registry/), we can use this registry to build and host our SimpleWebApp application. Assuming you only have one Container registry in your subscription you can get the name by running the following command.

```powershell
$ACR_NAME=az acr list --query '[].name' -otsv
```

We can the build the application by running the following command from the `lab3` directory

```powershell
az acr build --registry $ACR_NAME --image samplewebapp:v1 .
```

You should be able to find the image you just build if navigate to azure and search for `Container`, and select `Container registries`

![ACR image](./images/acr_search.png)

One you have navigated to your Container registry, you will find your image under `Repositories > samplewebapp`

![ACR image](./images/acr_image.png)

Before we deploy the container to our cluster lets first test it locally

```powershell
# login into to the azure container registry
az acr login -n $ACR_NAME
# run the application locally
docker run --rm -it -p 8082:80 "$($ACR_NAME).azurecr.io/samplewebapp:v1" 
```

Navigate to [http://localhost:8082](http://localhost:8082) and check that the output is the same as before.

We can now run and inspect this application in the cluster by running the following commands.

```powershell
kubectl run  --image "$($ACR_NAME).azurecr.io/samplewebapp:v1" samplewebapp
kubectl describe pod/samplewebapp
```

<!-- markdownlint-disable MD033 -->
<p>
<details>
  <summary>&#x261d; &#xfe0f; Hint </summary>
  <p>The describe command provides detailed information about the resource and any recent events that are associated with the resource. You can read more about this <a href="https://kubernetes.io/docs/tasks/debug-application-cluster/debug-application-introspection/#using-kubectl-describe-pod-to-fetch-details-about-pods">here</a></p>
</details>
</p>
<!-- markdownlint-enable MD033 -->

You can keep checking the describe command untill the pod state is `Running`
![POd is Ready](./images/pod_ready.png)

We could examine the pod by using the command below and navigating to [http://localhost:8083](http://localhost:8083)

```powershell
kubectl port-forward samplewebapp 8083:80
```

But instead we will expose the pod using a kubernetes service object. We will be diving into services in greater detail in Lab 5.

Lets run the commands below to expose the pod using a public IP address.

```powershell
kubectl expose po/samplewebapp --port 80 --type LoadBalancer
kubectl get service samplewebapp -w
```

The output of this command will looks like this:

```text
NAME           TYPE           CLUSTER-IP   EXTERNAL-IP   PORT(S)        AGE
samplewebapp   LoadBalancer   10.2.2.20    <pending>     80:31740/TCP   11s
```

After a while the `EXTERNAL-IP` state will change form `<pending>` to an IP address:

```text
NAME           TYPE           CLUSTER-IP   EXTERNAL-IP   PORT(S)        AGE
samplewebapp   LoadBalancer   10.2.2.20    <pending>     80:31740/TCP   11s
samplewebapp   LoadBalancer   10.2.2.20    20.93.176.14   80:31740/TCP   17s
```

We can now navigate to this IP address and see our now familiar web page.

## 2. Scaling up with ReplicaSets

Lets simulate an application error that crashes the pod by delting it

```powershell
kubectl delete po samplewebapp 
```

Our web application is now down and if we try to refresh the page we will get an error.

This is where `ReplicaSets` can help, they give us two great benefits:

1. We can have multiple instances (replicas) of the same pods running

2. Reconciliation loops, kubernetes will be continuously checking the desired state (number of replicas) vs the observed/current state, and will take action to ensure the observed state matches the desired state. You can read more about this [here](https://kubernetes.io/docs/concepts/architecture/controller/)

First lets delete the service, we will create another one soon.

```powershell
kubectl delete service/samplewebapp
```

Next create a file `samplewebapp.rs.yaml` and copy the content below into the file. Make sure to replace `<your-acr-name>` with `$ACR_NAME`

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  labels:
    app: samplewebapp
  name: samplewebapp
spec:
  replicas: 2
  selector:
    matchLabels:
      app: samplewebapp
  template:
    metadata:
      labels:
        app: samplewebapp
    spec:
      containers:
      - image: <your-acr-name>.azurecr.io/samplewebapp:v1
        name: samplewebapp
```

Now lets create the `ReplicaSet` and inspect the created resources

```powershell
kubectl apply -f ./samplewebapp.rs.yaml
kubectl get all
kubectl describe replicasets/samplewebapp
```

Lets expose the pods again but this time by exposing the `ReplicaSet`

```powershell
kubectl expose replicaset/samplewebapp --port 80 --type LoadBalancer
kubectl get service samplewebapp -w
```

One we have an IP address we should be able navigate to our web application. We can the delete one of the pods but the web application will still be available. Not only is our application still available, but aother pod will be scheduled to take the old pods place ensuring that we have the desired amout of pods running.

We can even delete all pods and our application will only be briefly unavailable.

```powershell
kubectl delete po --all
```

We can also scale the `ReplicaSet` up or down using the command below, obviously if you scale to `0` your web application won't be available.

```powershell
kubectl scale replicaset samplewebapp --replicas 5 
```

## 3. Managing your application with Deployments

It is unusual to create `ReplicaSets` and you should normally use the higher-level `Deployment` object. You can read more about this [here](https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#when-to-use-a-replicaset).

The `Deployments` expose the same api as `ReplicaSets` with a few additional features, in fact we can run the entire example in the previous chapter replacing all occurances of replicasets with deployments. You can read more about the use cases for deployments [here](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#use-case).

First let us delete the resources we just created.

```powershell
kubectl delete replicaset.apps/samplewebapp  service/samplewebapp
```

Now lets edit our web application, rebuild and run it using a new tag `v2`

```powershell
az acr build --registry $ACR_NAME --image samplewebapp:v2 .
docker run --rm -it -p 8082:80 "$($ACR_NAME).azurecr.io/samplewebapp:v2"
```

Next lets rename `samplewebapp.rs.yaml` file to `samplewebapp.deployment.yaml` and change the Kind property from `ReplicaSet` to `Deployment`.



<!-- Lets finish up by deleting the `lab3` namespace and resetting the default namespace in our configuration file.

```powershell
kubectl delete namespace lab3 
kubectl config set-context --current --namespace=default
``` -->

[:arrow_backward: previous](../lab2-exploring-k8s-api/LAB.md)  [next :arrow_forward:](../lab4-configuration/LAB.md)
