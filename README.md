# envsubst Dockerfile

This image will process a filename which is passed as an argument and substitute $FOO placeholders with ENVIRONMENT VARIABLE values.  A new file of the same name is written to the `/processed` directory.

This can be useful when running on Kubernetes and you wish to update placeholders in config files.  

This image can run as an init-container after mounting a configmap into `/workdir`.  Because config map files are readonly you'll also need to mount an `emptyDir: {}` volume to the init-container `/processed` folder as well as in the main pod container where you wish your new config to be mounted.

An example:
```
spec:
  replicas: 1
  template:
    metadata:
      annotations:
        pod.beta.kubernetes.io/init-containers: |-
          [
          {
            "name": "envvar-substitution",
            "image": "fabric8/envsubst-file",
            "imagePullPolicy": "IfNotPresent",
            "args": [
              "fabric8-realm.json"
            ],
            "env": [{
              "name": "PLACEHOLDER_URL",
              "value": "http://my.new.value"
            }],
            "volumeMounts": [
            {
              "name": "keycloak-config",
              "mountPath": "/workdir/fabric8-realm.json",
              "subPath": "config/fabric8-realm.json"
            },
            {
              "name": "keycloak-subst-config",
              "mountPath": "/processed"
            }
            ]
          }]
    spec:
      containers:
      - image: fabric8/keycloak-postgres:${keycloak.version}
        args:
        - -Dkeycloak.import=/opt/jboss/keycloak/standalone/configuration/import/fabric8-realm.json
        volumeMounts:
        - name: keycloak-subst-config
          mountPath: /opt/jboss/keycloak/standalone/configuration/import
      volumes:
      - name: keycloak-subst-config
        emptyDir: {}
      - name: keycloak-config
        configMap:
          name: keycloak
          items:
          - key: fabric8-realm.json
            path: config/fabric8-realm.json
```
