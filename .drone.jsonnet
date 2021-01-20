
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
      COVERAGE_RESULT_PATH: "coverage/clover.xml",  
      REPORT_PATH: "report.txt"
    }, 
    commands: [
        "echo  $PROJECT_NAME -  $REPORT_PATH",
        "echo url: ${COVERAGE_COLLECTOR_UPLOAD_URL} -  $COVERAGE_COLLECTOR_UPLOAD_URL",
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
    image: "ihealthlabs/coverage_plugin:v1.0.70", 
    environment:{
      COVERAGE_COLLECTOR_UPLOAD_URL: {
        from_secret: "COVERAGE_COLLECTOR_UPLOAD_URL",
      },
      COVERAGE_XML_PATH: "coverage/clover.xml",  
      REPORT_PATH: "report.txt" , 
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
        PLUGIN_MESSAGE: "report.txt",
    },
    depends_on: [
      "coverage",
      "rmOldReport"
    ],
    when: when
};
local redis(name, when) = {
    name: name,
    image: "redis",
    commands: [
            "sleep 5",
            "redis-cli -h localhost ping"
            ], 
    when: when
};

local mongo(name, when) = {
    name: name,
    image: "mongo:4",
    commands: [
            "mongo --host mongo --eval 'db.version();'",
            "date",
            "sleep 15",
            ], 
    when: when
};

local apiReportText( ) = {
    name: "name",
    image: "busybox:latest",
    environment:{
      COVERAGE_COLLECTOR_UPLOAD_URL: {
        from_secret: "COVERAGE_COLLECTOR_UPLOAD_URL",
      },
      // XMLS:{
      //   "Unit Test": "UI/clover.xml",
      //   "API Test": "IT/clover.xml",
      // },
      // FILES:{
      //   "Project Document": "target/site",
      // },
      REPORT_PATH: "report.txt", 
    }, 
    // commands: [
    //         "echo $XMLS",
    //         "echo $FILES",
    //         "echo \"${XMLS[Unit Test]}\"",
    //  ]  
};


local pipeline(branch, namespace, tag, instance) = {
    kind: 'pipeline',
    type: 'kubernetes',
    name: 'coveragePipeline',
    steps: [ 
      apiReportText()
        // redis("ping-redis", {instance: instance, event: ["pull_request"]}),
        // mongo("mongo-return-version", {instance: instance, event: ["pull_request"]}),
        // coverage("coverage", tag, {instance: instance, event: ["pull_request"]}),
        // outputReport("rmOldReport", tag, {instance: instance, event: ["pull_request"]}),
        // comments("1comment", tag, {instance: instance, event: ["pull_request"]})
    ],
    // services:[
    //   {
    //     name: "redis",
    //     image: "redis"
    //   },
    //   {
    //     name: 'mongo',
    //     pull: 'if-not-exists',
    //     image: 'mongo:4',
    //     environment: {
    //         MONGO_INITDB_ROOT_USERNAME: 'root',
    //         MONGO_INITDB_ROOT_PASSWORD: 'password',
    //         MONGO_INITDB_DATABASE: 'ShareCare'
    //     },
    //   }
    // ],
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
    pipeline(branch="test",
             namespace="sage",
             tag="${DRONE_BRANCH}-${DRONE_COMMIT:0:4}",
             instance=dev_drone)
 
    // define main pipeline
    // pipelineComments(branch="main",
    //          namespace="sage",
    //          tag="${DRONE_BRANCH}-${DRONE_COMMIT:0:4}",
    //          instance=dev_drone)
]


