# Lab 7 Deploying you applications with helm and Azure DevOps

## 1. Helm

Helm is the package manager for Kubernetes, it enables us to configure and deploy various Kubernetes resources using Helm Charts. Below are a few examples of chart that you can use to install applications into Kubernetes.

- [Keda](https://github.com/kedacore/charts)
- [Contour](https://github.com/bitnami/charts/tree/master/bitnami/contour/)
- [Jenkins](https://github.com/bitnami/charts/tree/master/bitnami/jenkins/)
- [Wordpress](https://bitnami.com/stack/wordpress/helm)
- [AAD Pod Identity](https://azure.github.io/aad-pod-identity/docs/getting-started/installation/#helm)
- [Application Gateway Ingress Controller](https://azure.github.io/application-gateway-kubernetes-ingress/setup/install-new/#install-ingress-controller-helm-chart)

Let's deploy the wordpress Helm Chart. First let's see what resources get deployed.

```powershell
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install wordpress --create-namespace --dry-run  -n wordpress bitnami/wordpress
```

This should print out all the resources this chart will create and then the instruction to access the wordpress installation one the deployment is done. 

Let's deploy the Chart.

```powershell
helm install wordpress --create-namespace -n wordpress bitnami/wordpress
```

Once you have inspected the installed resources you can delete the installation by running the following command.

```powershell
helm delete wordpress -n wordpress
```

We can also use Helm charts to define our own applications so can we dynamically apply configuration and deploy our applications.

Go through the following sections of the Chart Template Guide of the helm [docs](https://helm.sh/docs/chart_template_guide/getting_started/)

- Getting Started
- Built-in Objects
- Values Files
- Template Functions and Pipelines
- Flow Control
- Variables
- Debugging Templates

## 2. Deploying an application using Helm and Azure DevOps

We will spend the rest of this lab trying to deploy a sample application to Kubernetes using Helm and Azure DevOps. The idea is that you deploy the application to a test environment and then on to a production environment.  

These environments need to to have their own resources and should be configured seperately.

[:arrow_backward: previous](../lab6-volumes/LAB.md)  [next :arrow_forward:](../lab8-troubleshooting/LAB.md)