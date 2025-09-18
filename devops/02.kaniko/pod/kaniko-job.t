apiVersion: batch/v1
kind: Job
metadata:
  name: ${USER_NAME}-kaniko-build-${HASHCODE}
  namespace: ${NAMESPACE}
  labels:
    app: ${USER_NAME}
spec:
  template:
    metadata:
      labels:
        app: ${USER_NAME}
    spec:
      containers:
      - name: kaniko
        image: gcr.io/kaniko-project/executor:latest
        args:
          - --dockerfile=/workspace/Dockerfile
          - --context=dir:///workspace
          - --destination=${DOCKER_REGISTRY}/${USER_NAME}-kaniko-build-app:${VERSION}
        volumeMounts:
          - name: kaniko-secret
            mountPath: /kaniko/.docker
          - name: workspace
            mountPath: /workspace
      restartPolicy: Never
      volumes:
        - name: kaniko-secret
          secret:
            secretName: harbor-registry-secret
            items:
              - key: .dockerconfigjson
                path: config.json  # /kaniko/.docker/config.json 파일로 마운트됨
        - name: workspace
          configMap:  # 또는 PVC, emptyDir, gitRepo 등
            name: kaniko-app-workspace

