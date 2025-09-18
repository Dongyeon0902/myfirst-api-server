apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerBinding
metadata:
  name: ${USER_NAME}-springboot-binding
  namespace: skala-tekton
spec:
  params:
    - name: git-url
      value: $(body.repository.clone_url)
    - name: git-revision
      value: $(body.ref)

