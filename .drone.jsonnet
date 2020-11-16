
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
    image: "ihealthlabs/coverage_webhook:0.5",
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
      COVERAGE_COLLECTOR_UPLOAD_URL: {
        from_secret: "COVERAGE_COLLECTOR_UPLOAD_URL",
      },
      PROJECT_NAME: "DRONE_REPO",
      BASE_BRANCH: "DRONE_SOURCE_BRANCH",
      COMPARING_BRANCH: "DRONE_TARGET_BRANCH",
      BASE_COMMIT_ID: "DRONE_COMMIT",
      COMPARING_COMMIT_ID: "DRONE_COMMIT",
      ACTION: "DRONE_BUILD_EVENT",
      FILE: "small_clover.xml"
    },
    //  commands: [
    //     "echo COVERAGE_COLLECTOR_UPLOAD_URL: ${COVERAGE_COLLECTOR_UPLOAD_URL}",
    //     "echo 黑色: ${PROJECT_NAME}",
    //     "export PROJECT_NAME=${DRONE_REPO}",
    //     "export BASE_BRANCH=${DRONE_SOURCE_BRANCH}",
    //     "export COMPARING_BRANCH=${DRONE_TARGET_BRANCH}",
    //     "export BASE_COMMIT_ID=${DRONE_COMMIT}",
    //     "export COMPARING_COMMIT_ID=${DRONE_COMMIT}",
    //     "export ACTION=${DRONE_BUILD_EVENT}",
    //     "export FILE=small_clover.xml",
    //     "echo ACTION: ${ACTION}",
    //      "pwd ",
    //      "ls   /drone/src",
    //      "/bin/curl.sh",
    //      "ls  /bin/ ",
    //      "ls   /drone/src",
    // ],
    when: when
};

local Comments(name, message, when) = {
    name: name,
    image: "ihealthlabs/test_image:drone-github-comment-1.0",
    pull: "always",
    environment:{
        PLUGIN_API_KEY: 
        {
            from_secret: "APIKEY"
        },
        // PLUGIN_MESSAGE: "/drone/src/coverage.svg",//message
        PLUGIN_MESSAGE: " <h3 style='color: red'> cov is 89%. was 90%  </h3>  <img src='https://camo.githubusercontent.com/45ed0ba7a64790deee9aa16cf0d44756c72624a05f67a9cc51705fa480cc741e/68747470733a2f2f75732e6a656e6b696e732e696865616c74686e6578742e636f6d2f2f636f7665726167652d7374617475732d69636f6e2f3f636f7665726167653d302e36383736266d6173746572436f7665726167653d302e363837'></img>",//message
    },
    when: when
};

local pipeline(branch,
               namespace, tag, instance) = {
    kind: 'pipeline',
    type: 'kubernetes',
    name: branch,
    steps: [
        // publish(branch+"-publish", tag, {instance: instance, event: ["push"]}),
        coverage(branch+"-coverage", tag, {instance: instance, event: ["push", "pull_request"]}),
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
             instance=dev_drone),
 
    // define main pipeline
    pipeline(branch="main",
             namespace="sage",
             tag="${DRONE_BRANCH}-${DRONE_COMMIT:0:4}",
             instance=dev_drone)
]


