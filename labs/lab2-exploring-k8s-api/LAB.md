# Lab 2.  Explore kubernetes using the various tools.

#### In this lab we will explore the kubernetes api using the proxy, kubectl, VS Code, the azure portal and C#

## 1. Explore the apiserver using the proxy
Run the following command to start the proxy. The proxy will handle exposing and authentication to the kubernetes apiserver.

```powershell
kubectl proxy --port 8080
```

Open another powershell terminal to start exploring the api, and run the following command to set the api url.

```powershell
$api = "http://localhost:8080"
```

We can now start exploring the kubeserver api, run the following command to query the api versions.

```powershell
Invoke-RestMethod -Uri $api/api | ConvertTo-Json
```
<!-- markdownlint-disable MD033 -->
<p>
<details>
  <summary>&#x261d; &#xfe0f; Hint </summary>
  <p>You can colorize the output by using <a href="https://stedolan.github.io/jq/download">jq</a>, you can then view the colorized output by </p>

```powershell
  Invoke-RestMethod -Uri $api/api | ConvertTo-Json | jq -C
```
</details>
</p>
<!-- markdownlint-enable MD033 -->

Run the following command to query the nodes in the cluster

```powershell
Invoke-RestMethod -Uri $api/api/v1/nodes | ConvertTo-Json
```

Run the following command to query the namespaces in the cluster

```powershell
Invoke-RestMethod -Uri $api/api/v1/namespaces | ConvertTo-Json
```

Run the following command to query the pods in the kube-system namespace

```powershell
Invoke-RestMethod -Uri $api/api/v1/namespaces/kube-system/pods | ConvertTo-Json
```

## 2. Explore the apiserver using kubeclt cli

## 3. Explore the apiserver using azure portal

## 4. Explore the apiserver using C# and .Net Core

[:arrow_backward: previous](../lab1-environment-setup/LAB.md)  [next :arrow_forward:](../lab3-workloads/LAB.md)
