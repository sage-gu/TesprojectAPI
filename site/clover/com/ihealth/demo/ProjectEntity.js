var clover = new Object();

// JSON: {classes : [{name, id, sl, el,  methods : [{sl, el}, ...]}, ...]}
clover.pageData = {"classes":[{"el":44,"id":212,"methods":[{"el":18,"sc":5,"sl":14},{"el":22,"sc":5,"sl":20},{"el":28,"sc":5,"sl":24},{"el":32,"sc":5,"sl":30},{"el":38,"sc":5,"sl":34},{"el":42,"sc":5,"sl":40}],"name":"ProjectEntity","sl":9}]}

// JSON: {test_ID : {"methods": [ID1, ID2, ID3...], "name" : "testXXX() void"}, ...};
clover.testTargets = {"test_1":{"methods":[{"sl":14},{"sl":20},{"sl":24},{"sl":34},{"sl":40}],"name":"getAllProjects","pass":true,"statements":[{"sl":17},{"sl":21},{"sl":27},{"sl":37},{"sl":41}]},"test_2":{"methods":[{"sl":30},{"sl":40}],"name":"analyseCoverage","pass":true,"statements":[{"sl":31},{"sl":41}]},"test_7":{"methods":[{"sl":40}],"name":"getAllProjects","pass":true,"statements":[{"sl":41}]}}

// JSON: { lines : [{tests : [testid1, testid2, testid3, ...]}, ...]};
clover.srcFileLines = [[], [], [], [], [], [], [], [], [], [], [], [], [], [], [1], [], [], [1], [], [], [1], [1], [], [], [1], [], [], [1], [], [], [2], [2], [], [], [1], [], [], [1], [], [], [2, 1, 7], [2, 1, 7], [], [], []]
