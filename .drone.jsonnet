
local publish(name, tag, when) = {
    name: name,
    pull: "if-not-exists",
    image: "ubuntu:latest",
    settings:{
        repo: "sage-gu/TesprojectAPI",
        tags:[
            tag
          ],
        username:{
          from_secret: "DOCKER_USERNAME",
        },
        password:{
          from_secret: "DOCKER_PASSWORD",
        }
    },
     commands: [
        "echo branch: ${DRONE_BRANCH} - buildEvent: ${DRONE_BUILD_EVENT}",
        "echo target branch for the push or pull request DRONE_COMMIT_BRANCH: ${DRONE_COMMIT_BRANCH} - DRONE_SOURCE_BRANCH: ${DRONE_SOURCE_BRANCH}",
        "echo DRONE_TARGET_BRANCH: ${DRONE_TARGET_BRANCH}",
        "echo DRONE_COMMIT: ${DRONE_COMMIT}"
        // "apt-get update",
        // "apt-get -y install curl",
        // "curl 20.0.101.155:31743/cc/allprojects ",
        // "curl baidu.com"
    ],
    when: when
};

local coverage(name, tag, when) = {
    name: name,
    // pull: "if-not-exists",
    image: "ihealthlabs/coverage_webhook:0.2",
    settings:{
        repo: "sage-gu/TesprojectAPI",
        tags:[
            tag
          ],
        username:{
          from_secret: "DOCKER_USERNAME",
        },
        password:{
          from_secret: "DOCKER_PASSWORD",
        },
        PLUGIN_URL: "https://baidu.com",
        PLUGIN_BODY:"hello",
        PLUGIN_METHOD: "get"
    },
    environment:{
      PROJECT_NAME: "https://baidu.com",
      BASE_BRANCH:"hello",
      PLUGIN_METHOD: "get"
    },
     commands: [
        "echo DRONE_COMMIT: ${DRONE_COMMIT}",
        "echo PROJECT_NAME: ${PROJECT_NAME}",
        "export PROJECT_NAME=${DRONE_REPO}",
         "export BASE_BRANCH=${DRONE_SOURCE_BRANCH}",
         "export COMPARING_BRANCH=${DRONE_TARGET_BRANCH}",
         "export BASE_COMMIT_ID${DRONE_COMMIT}",
         "export COMPARING_COMMIT_ID=${DRONE_COMMIT}",
         "export ACTION=${DRONE_BUILD_ACTION}",
         "export FILE=clover.xml",
         "./bin/curl.sh"
    ],
    when: when
};

local pipeline(branch,
               namespace, tag, instance) = {
    kind: 'pipeline',
    type: 'kubernetes',
    name: branch,
    steps: [
        // publish(branch+"-publish", tag, {instance: instance, event: ["push"]}),
        coverage(branch+"-coverage", tag, {instance: instance, event: ["push"]}),
    ],
    trigger:{
        branch: branch
    },
    image_pull_secrets: ["dockerconfigjson"]
};

local dev_drone = ["dev-drone.ihealth-eng.com"];
local test_drone = ["test-drone.ihealth-eng.com"];
local prod_drone = ["prod-drone.ihealth-eng.com"];

[
    // define dev pipeline
    pipeline(branch="dev",
             namespace="sage",
             tag="${DRONE_BRANCH}-${DRONE_COMMIT:0:4}",
             instance=dev_drone)
]
