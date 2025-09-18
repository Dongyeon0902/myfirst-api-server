apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: ${USER_NAME}-springboot-trigger-template
  namespace: skala-tekton
spec:
  params:
    - name: git-url
    - name: git-revision
  resourcetemplates:
    - apiVersion: tekton.dev/v1beta1
      kind: PipelineRun
      metadata:
        generateName: ${USER_NAME}-push-pipeline-run-
      spec:
        pipelineRef:
          name: push-pipeline-sa
        params:
          - name: git-url
            value: $(tt.params.git-url)
          - name: git-revision
            value: $(tt.params.git-revision)
          - name: image-registry
            value: "amdp-registry.skala-ai.com/skala25a"
          - name: image-name
            value: "${USER_NAME}-my-app"
          - name: image-tag
            value: "1.0.kaniko-docker"
        workspaces:
          - name: shared-workspace
            persistentVolumeClaim:
              claimName: ${USER_NAME}-shared-workspace-pvc
          - name: maven-settings
            persistentVolumeClaim:
              claimName: ${USER_NAME}-shared-workspace-pvc
          - name: maven-local-repo
            persistentVolumeClaim:
              claimName: ${USER_NAME}-shared-workspace-pvc
        serviceAccountName: ${USER_NAME}-pipeline-sa

