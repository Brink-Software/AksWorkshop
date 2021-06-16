# Lab 4. Configuring your kubernetes applications 

## 1. Configuring your application using environment variables.

In 2011 the developers at [Heroku](https://www.heroku.com/) presented a methodology for building software-as-a-service application [The Twelve-Factor App](https://12factor.net/) methodology. The 3rd of these twelve factors is to store config in the environment you can read more about this [here](https://12factor.net/config). Containerized application allow us to set environment variables to provide dynamic configuration. 

## 2. Configuring sensitive information using `Secrets`

## 3. Preventing resource starvation with resource request and limits

From the [docs](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#resource-types):
> **Note:** If a Container specifies its own memory limit, but does not specify a memory request, Kubernetes automatically assigns a memory request that matches the limit. Similarly, if a Container specifies its own CPU limit, but does not specify a CPU request, Kubernetes automatically assigns a CPU request that matches the limit.

## 4. Configuring Liveness, Readiness, Startup probes and pod lifecycle.

## 5. Using managed pod identity to access key vault secrets

## 6. Managing pod placement

## 7. Configuring apiserver access with Pod Service accounts

[:arrow_backward: previous](../lab3-workloads/LAB.md)  [next :arrow_forward:](../lab5-networking/LAB.md)