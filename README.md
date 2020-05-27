## renku-openshift
https://renku.readthedocs.io/en/latest/

#### Deploy

```bash
./deploy-renku.sh
```

This will create three new namespaces:
* tiller
* acme
* renku

And deploy these services/components:
* `tiller` for Helm to be working correctly
* tool for generating Let's encrypt certs based on annotation on route resource
* Nginx that works as a reverse proxy
* Renku - https://renku.readthedocs.io/en/latest/

#### Undeploy

```bash
./undeploy-renku-sh
```
