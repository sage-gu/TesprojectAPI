
local outputReport(name, tag, when) = {
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
    environment:{
      COVERAGE_COLLECTOR_UPLOAD_URL: {
        from_secret: "COVERAGE_COLLECTOR_UPLOAD_URL",
      },
      PROJECT_NAME: "${DRONE_REPO}",
      BASE_BRANCH: "${DRONE_SOURCE_BRANCH}",
      COMPARING_BRANCH: "${DRONE_TARGET_BRANCH}",
      BASE_COMMIT_ID: "${DRONE_COMMIT}",
      ACTION: "${DRONE_BUILD_EVENT} + ${DRONE_BUILD_ACTION}",
      COVERAGE_RESULT_PATH: "small_clover.xml",  
      REPORT_PATH: "report.txt"
    }, 
    commands: [
        "echo REPORT_PATH: ${REPORT_PATH} -  $REPORT_PATH",
        "echo REPORT_PATH: ${COVERAGE_COLLECTOR_UPLOAD_URL} -  $REPORT_PATH",
        "pwd; ls -l",
        "cat /drone/src/report.txt"
    ],
    depends_on: [
      "coverage",
    ],
    when: when
};

local coverage(name, tag, when) = {
    name: name,
    image: "ihealthlabs/coverage_collector_docker_plugin:v1.0.57",
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
    },
    environment:{
      COVERAGE_COLLECTOR_UPLOAD_URL: {
        from_secret: "COVERAGE_COLLECTOR_UPLOAD_URL",
      },
      PROJECT_NAME: "${DRONE_REPO}",
      BASE_BRANCH: "${DRONE_SOURCE_BRANCH}",
      COMPARING_BRANCH: "${DRONE_TARGET_BRANCH}",
      BASE_COMMIT_ID: "${DRONE_COMMIT}",
      ACTION: "${DRONE_BUILD_EVENT} + ${DRONE_BUILD_ACTION}",
      COVERAGE_RESULT_PATH: "clover.xml",  
      DIRECTORY: "/drone/src/site/clover",
      REPORT_PATH: "report.txt" 
    }, 
    when: when
};

local comments(name, message, when) = {
    name: name,
    image: "ihealthlabs/test_image:drone-github-comment-1.0",
    pull: "always",
    environment:{
        PLUGIN_API_KEY: 
        {
            from_secret: "APIKEY"
        },
        //PLUGIN_MESSAGE: "[ccc](https://us.jenkins.ihealthnext.com/job/sharecare-gql-unit-tests/clover/cron/system_msg/_utils.js.html)"//"
        PLUGIN_MESSAGE: "/drone/src/report.txt",//message 
    },
    depends_on: [
      "coverage",
      "rmOldReport"
    ],
    when: when
};

local pipeline(branch, namespace, tag, instance) = {
    kind: 'pipeline',
    type: 'kubernetes',
    name: 'coveragePipeline',
    steps: [
        coverage("coverage", tag, {instance: instance, event: ["pull_request"]}),
        outputReport("rmOldReport", tag, {instance: instance, event: ["pull_request"]}),
        comments("1comment", tag, {instance: instance, event: ["pull_request"]})
    ],
    // trigger:{
    //     branch: branch
    // },
    image_pull_secrets: ["dockerconfigjson"]
};

local pipelineComments(branch, namespace, tag, instance) = {
    kind: 'pipeline',
    type: 'kubernetes',
    name: "commentsPipeline",
    steps: [
        comments("comment", tag, {instance: instance, event: ["pull_request"]})
    ],
    trigger:{
        branch: branch
    },
    depends_on: [
      "coveragePipeline"
    ],
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
 
    // define main pipeline
    // pipelineComments(branch="main",
    //          namespace="sage",
    //          tag="${DRONE_BRANCH}-${DRONE_COMMIT:0:4}",
    //          instance=dev_drone)
]


