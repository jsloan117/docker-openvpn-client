#!/bin/bash
# build, test and push docker images

set -euo pipefail

if [[ "${ENABLE_DEBUG}" = true ]]; then
  set -xv
fi

if [[ "${TRAVIS_BRANCH}" = master ]]; then
  IMAGE_TAG=latest
else
  IMAGE_TAG="${TRAVIS_BRANCH}"
fi
export IMAGE_TAG

get_version () {
  echo -e '\n<<< Getting & setting versioning info >>>\n'
  # allows for starting semantic versioning & overriding auto-calculated value (set within TravisCI)
  if [[ -n "${SEMVER_OVERRIDE}" ]]; then
    echo "${SEMVER_OVERRIDE}" > VERSION
    NEXT_VERSION=$(cat VERSION)
    echo "Version: ${NEXT_VERSION}"
  else
    CURRENT_VERSION=$(docker run --entrypoint="" --rm "${IMAGE_NAME}":"${IMAGE_TAG}" cat VERSION 2> /dev/null)
    echo "${CURRENT_VERSION}" > VERSION
    NEXT_VERSION=$(docker run --rm -it -v "${PWD}":/app -w /app treeder/bump --filename VERSION "${SEMVER_BUMP}")
    echo "Version: ${NEXT_VERSION}"
  fi
  export NEXT_VERSION
}

build_images () {
  [[ "${TRAVIS_BRANCH}" != master ]] && touch VERSION
  echo -e '\n<<< Building default image >>>\n'
  docker build --rm -f Dockerfile -t "${IMAGE_NAME}":"${IMAGE_TAG}" --build-arg REVISION="${TRAVIS_COMMIT}" .
  for DISTRO in $(find . -type f -iname "Dockerfile.*" -print | cut -d'/' -f2 | cut -d'.' -f 2); do
    echo -e "\n<<< Building ${DISTRO} image >>>\n"
    docker build --rm -f Dockerfile."${DISTRO}" -t "${IMAGE_NAME}":"${IMAGE_TAG}"-"${DISTRO}" --build-arg REVISION="${TRAVIS_COMMIT}" .
  done
  if docker image ls | tail -n+2 | awk '{print $2}'| grep '<none>' &> /dev/null; then
    echo -e '\n<<< Cleaning up dangling images >>>\n'
    docker rmi "$(docker images -f dangling=true -q)" 2>&-
  fi
}

install_prereqs () {
  echo -e '\n<<< Installing (d)goss & trivy prerequisites >>>\n'
  # goss/dgoss (server-spec for containers)
  GOSS_VER=$(curl -s "https://api.github.com/repos/aelsabbahy/goss/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
  export GOSS_VER
  curl -sL "https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VER}/goss-linux-amd64" -o "${HOME}/bin/goss"
  curl -sL "https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VER}/dgoss" -o "${HOME}/bin/dgoss"
  # trivy (vuln scanner)
  TRIVY_VER=$(curl -s "https://api.github.com/repos/aquasecurity/trivy/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
  export TRIVY_VER
  wget -q "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VER}/trivy_${TRIVY_VER}_Linux-64bit.tar.gz"
  tar -C "${HOME}/bin" -zxf "trivy_${TRIVY_VER}_Linux-64bit.tar.gz" trivy
  chmod +rx "${HOME}"/bin/{goss,dgoss}
}

vulnerability_scanner () {
  trivy --clear-cache
  for IMAGE in $(docker image ls | tail -n+2 | awk '{OFS=":";} {print $1,$2}'| grep "${DOCKER_USER}"); do
    echo -e "\n<<< Checking ${IMAGE} for vulnerabilities >>>\n"
    trivy --exit-code 0 --severity "UNKNOWN,LOW,MEDIUM,HIGH" --light -q "${IMAGE}"
    echo -e "\n<<< Checking ${IMAGE} for critical vulnerabilities >>>\n"
    trivy --exit-code 1 --severity CRITICAL --light -q "${IMAGE}"
  done
}

test_images () {
  for IMAGE in $(docker image ls | tail -n+2 | awk '{OFS=":";} {print $1,$2}'| grep "${DOCKER_USER}"); do
    echo -e "\n<<< Testing ${IMAGE} image >>>\n"
    dgoss run -e PUID=1000 -e PGID=1000 "${IMAGE_NAME}":"${IMAGE_TAG}"
  done
}

push_images () {
  echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin &> /dev/null
  if [[ "${TRAVIS_BRANCH}" = dev ]]; then
    for IMAGE in $(docker image ls | tail -n+2 | awk '{OFS=":";} {print $1,$2}'| grep "${DOCKER_USER}"); do
      echo -e "\n<<< Pushing ${IMAGE} image >>>\n"
      docker push "${IMAGE}"
    done
  elif [[ "${TRAVIS_BRANCH}" = master ]]; then
    docker tag "${IMAGE_NAME}":"${IMAGE_TAG}" "${IMAGE_NAME}":"${NEXT_VERSION}"
    for DISTRO in $(find . -type f -iname "Dockerfile.*" -print | cut -d'/' -f2 | cut -d'.' -f 2); do
      docker tag "${IMAGE_NAME}":"${IMAGE_TAG}"-"${DISTRO}" "${IMAGE_NAME}":"${NEXT_VERSION}"-"${DISTRO}"
    done
    for IMAGE in $(docker image ls | tail -n+2 | awk '{OFS=":";} {print $1,$2}'| grep "${DOCKER_USER}"); do
      echo -e "\n<<< Pushing ${IMAGE} image >>>\n"
      docker push "${IMAGE}"
    done  
  fi
}

if [[ "${TRAVIS_BRANCH}" = master ]]; then
  get_version
fi
build_images
if [[ "${VULNERABILITY_TEST}" = true || "${DGOSS_TEST}" = true ]]; then
  install_prereqs
fi
if [[ "${VULNERABILITY_TEST}" = true ]]; then
  vulnerability_scanner
fi
if [[ "${DGOSS_TEST}" = true ]]; then
  test_images
fi
if [[ "${TRAVIS_PULL_REQUEST}" = false ]] && [[ "${TRAVIS_BRANCH}" =~ ^(dev|master)$ ]]; then
  push_images
fi
