# Lab 8. Troubleshooting Deployments

Examine the Helm chart located in the folder [exercises/lab8](../../exercises/lab8). Deploy the chart to the cluster using any method you like and watch it fail. 

In this lab we will expose a website that can be reached using the url http://failure.com. In order for the browser to resolve this url we need to map the public IP of the gateway to this url. We will do this by editing the file `c:\windows\system32\drivers\etc\hosts`

Add the line `<your-public-ip> failure.com` to the file and save it. Make sure your editor runs with administrator permissions to be able to save the file.

If you have troubles deploying the chart take a look at the hint below.

<!-- markdownlint-disable MD033 -->
<p>
<details>
  <summary>&#x261d; &#xfe0f; Helm command </summary>
  <p>One way to deploy the chart is using the helm command like this:</p>

```
helm upgrade failure .\helm\ --install --namespace lab8 --wait --atomic --create-namespace --values .\helm\values.yaml
```
</details>
</p>
<!-- markdownlint-enable MD033 -->

Your job for this lab is to identitify the problems, solve them and get the deployment up and running. When all issues are resolved the result should look like this:

![The working application](./images/result.png)

## Resources

Ways to troubleshoot your application:

[Troubleshoot Applications](https://kubernetes.io/docs/tasks/debug-application-cluster/debug-application/#debugging-pods)

There is also this short video guiding you through some options.
[![How To Debug A Kubernetes Application](https://res.cloudinary.com/marcomontalbano/image/upload/v1623867284/video_to_markdown/images/youtube--aCcIdG82KxA-c05b58ac6eb4c4700831b2b3070cd403.jpg)](https://www.youtube.com/watch?v=aCcIdG82KxA "How To Debug A Kubernetes Application")

Finally, you can also refer to this [Kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/) to look up commands that can help you in troubleshooting.

## Questions

- How many problems did you solve?
- What are the symptoms of the problems?
- How did you solve them?

<!-- markdownlint-disable MD033 -->
<details>
  <summary>&#127873; Bonus</summary>

In the ingress definition, change line 16 to 

```
serviceName: {{ include "failure.name" . }}-service
```

Then deploy the chart and observe that the deployment is not working.

- How can you find out what the problem is?

</details>
<!-- markdownlint-enable MD033 -->

## Solutions

A detailed solution can be found [here](./solution/SOLUTION.md). But we urge you to try to solve the problem yourself first! 

[:arrow_backward: previous](../lab7-deploy/LAB.md)  [next :arrow_forward:](../lab9-quiz/LAB.md)