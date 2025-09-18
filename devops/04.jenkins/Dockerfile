#FROM jenkins/jenkins:lts
FROM jenkins/jenkins:lts-jdk17

USER root

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common \
    git \
    python3 \
    python3-pip \
    wget \
    unzip \
    sudo \
    jq \
    # Java JDK 설치 (OpenJDK 17) \
    openjdk-17-jdk \
    # Maven 설치 \
    maven \
    && rm -rf /var/lib/apt/lists/*


# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$(dpkg --print-architecture)/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/ && \
    kubectl version --client

# 현대적인 방법으로 Docker 저장소 키 설정
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg

# 시스템 아키텍처 감지하여 Docker 저장소 추가 후 Docker CLI만 설치
RUN ARCH=$(dpkg --print-architecture) && \
    echo \
    "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# Dockerfile에 sudo 설치 추가
RUN apt-get update && apt-get install -y sudo && \
    echo "jenkins ALL=(ALL) NOPASSWD: /usr/bin/docker" >> /etc/sudoers

# Docker 소켓 접근을 위한 권한 설정
RUN groupadd -f docker && \
    usermod -aG docker jenkins

# GitHub CLI 설치 (webhook 설정 자동화를 위해)
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
    tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh && \
    rm -rf /var/lib/apt/lists/*

# Maven 설정 확인 및 경로 설정
RUN mvn --version && \
    echo "export MAVEN_HOME=/usr/share/maven" >> /etc/profile.d/maven.sh

# Java 환경 변수 설정
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-$(dpkg --print-architecture)" >> /etc/profile.d/java.sh && \
    echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> /etc/profile.d/java.sh

# Gradle 설치 (최신 버전)
ENV GRADLE_VERSION=8.5
RUN wget https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -P /tmp && \
    unzip -d /opt /tmp/gradle-${GRADLE_VERSION}-bin.zip && \
    ln -s /opt/gradle-${GRADLE_VERSION} /opt/gradle && \
    rm /tmp/gradle-${GRADLE_VERSION}-bin.zip

# Gradle 환경 변수 설정
ENV GRADLE_HOME=/opt/gradle
ENV PATH=$PATH:$GRADLE_HOME/bin

RUN apt-get update && \
    apt-get install -y sudo && \
    echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch back to Jenkins user
USER jenkins

# Skip setup wizard
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

# JCasC 환경 변수 설정
ENV CASC_JENKINS_CONFIG=/var/jenkins_config/jenkins.yaml

# Copy plugin installation script
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt

RUN jenkins-plugin-cli \
    --plugin-download-directory /usr/share/jenkins/ref/plugins \
    --plugin-file /usr/share/jenkins/ref/plugins.txt \
    --latest \
    --verbose

# Install plugins
RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/ref/plugins.txt


# Expose Jenkins port
EXPOSE 8080
EXPOSE 50000

# Set volume for Jenkins home
#RUN mkdir -p /var/jenkins_home/.kube
#COPY --chown=1000:1000 kube-config /var/jenkins_home/.kube/config
COPY --chown=1000:1000 kube-config /usr/share/jenkins/ref/kube-config

ENV COPY_REFERENCE_FILE_LOG=/var/jenkins_home/copy_reference_file.log
ENV KUBECONFIG=/usr/share/jenkins/ref/kube-config
