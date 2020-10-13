
import requests
import json
# from requests_toolbelt.multipart import encoder
from requests_toolbelt import MultipartEncoder, MultipartEncoderMonitor


token_string = 'F-2LvppZzzHvbsNHx6CfhCwhcTfQSpexHmem7dTMwoQ1'

projectId = 'YBUHozJ_CE61sqbmzeBi-g'
appId = 'tNTQ-b6pPEWwgp_-cjcmdg'

appId_dev_Android = 'pN_i_FqWS0qG0FZ5cft76Q'
appId_dev_iOS = 'isvOaZVfYEOnDxdxNen8FQ'
appId_product_Android = 'YICJNVLdw06T-HZPIRKb4w'
appId_product_iOS = 'tNTQ-b6pPEWwgp_-cjcmdg'
appId_test_Android = 'IE4EQbuLqU-2UHknI-bXeg'
appId_test_iOS = '8nXjTpPyiUudldbkDJaSHA'


def uploadApplication(theId, platform_env, file_path, file_name):
    appId = theId
    host = 'https://api.testproject.io/v2/projects/'
    url_prefix = host + projectId + '/applications/' + appId
    headers = {'content-type': 'application/json', "Authorization": "{}".format(token_string)}

    print("get upload-link " + platform_env)
    response_uploadurl = requests.get(url_prefix + '/file/upload-link', headers=headers)
    data = json.loads(response_uploadurl.text)

    # with open("/Users/sagegu/Downloads/bb.ipa", "rb") as a_file:
    #     file_dict = {"abc.ipa": a_file}
    #     response = requests.put(data['url'], files=file_dict)
    
    #     print(response)
    #     print(response.text)
    #     print(response.status_code)

    # upload and show progress
    def my_callback(monitor):
        # Your callback function
        print (monitor.bytes_read)

    e = MultipartEncoder(
        { file_name: open(file_path, 'rb') }
        )
    m = MultipartEncoderMonitor(e, my_callback)
    r = requests.put(data['url'], data=m )


    # ---------------------
    # Confirm file uploaded
    print("Confirm upload")
    confirm_file = host + projectId + '/applications/' + appId + '/file'
    payload = {'fileName': file_name}
    confirm_file_response = requests.post(confirm_file, data=json.dumps(payload), headers=headers)
    print(confirm_file_response.status_code)                  

uploadApplication(appId_product_iOS, 'product ios', '/Users/sagegu/Desktop/1/personalAppRN.ipa', 'prod_ios.ipa')