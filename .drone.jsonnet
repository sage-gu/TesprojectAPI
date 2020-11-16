
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
    image: "ihealthlabs/coverage_webhook:0.3",
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
        A_NAME: "https://baidu.com",
        PLUGIN_BODY:"hello",
        PLUGIN_METHOD: "get"
    },
    environment:{
      A_NAME: "https://baidu.com",
      BASE_BRANCH:"hello",
      PLUGIN_METHOD: "get",
      COVERAGE_COLLECTOR_URL: {
        from_secret: "COVERAGE_COLLECTOR_URL",
      },
    },
     commands: [
        "echo COVERAGE_COLLECTOR_URL: ${COVERAGE_COLLECTOR_URL}",
        "echo PROJECT_NAME: ${PROJECT_NAME}",
        "export PROJECT_NAME=${DRONE_REPO}",
         "export BASE_BRANCH=${DRONE_SOURCE_BRANCH}",
         "export COMPARING_BRANCH=${DRONE_TARGET_BRANCH}",
         "export BASE_COMMIT_ID=${DRONE_COMMIT}",
         "export COMPARING_COMMIT_ID=${DRONE_COMMIT}",
         "export ACTION=${DRONE_BUILD_EVENT}",
         "export FILE=clover.xml",
        "echo ACTION: ${ACTION}",
         "pwd ",
         "ls   /bin/ ",
         "/bin/curl.sh",

         "ls  /bin/ ",
    ],
    when: when
};

local Comments(name, message, when) = {
    name: name,
    image: "ihealthlabs/test_image:drone-github-comment-1.0",
    pull: "always",
    environment:{
        "PLUGIN_API_KEY": 
        {
            from_secret: "APIKEY"
        },
        "PLUGIN_MESSAGE": "/bin/coverage.svg",//message
    },
    commands: [
      "echo ACTION: ${PLUGIN_MESSAGE}",
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
        Comments(branch+"-comment", tag, {instance: instance, event: ["pull_request"]})
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
