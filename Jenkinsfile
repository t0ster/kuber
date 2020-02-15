podTemplate(
        containers: [
                containerTemplate(name: 'jnlp', image: 'jenkins/jnlp-slave'),
                containerTemplate(name: 'selenium', alwaysPullImage: true, image: "t0ster/kuber-selenium:${BRANCH_NAME}", command: 'cat', ttyEnabled: true, envVars: [
                    envVar(key: 'SELENIUM_HOST', value: 'zalenium'),
                    envVar(key: 'BASE_URL', value: "http://stg.kuber.35.246.75.225.nip.io"),
                    envVar(key: 'BUILD', value: "kuber-${BRANCH_NAME}-${BUILD_ID}"),
                ]),
        ]
) {
    node(POD_LABEL) {
        stage('Deploy') {
            def patchOrg = """
                {
                    "release": "kuber-stg",
                    "repo": "https://github.com/t0ster/kuber.git",
                    "path": "charts/kuber-stack",
                    "namespace": "stg",
                    "branch": "${BRANCH_NAME}",
                    "values": {
                        "host": "stg.kuber.35.246.75.225.nip.io",
                        "ui": {
                            "image": {
                                "pullPolicy": "Always",
                                "release": "kuber-${BRANCH_NAME}-${BUILD_ID}"
                            }
                        },
                        "functions": {
                            "image": {
                                "pullPolicy": "Always",
                                "release": "kuber-${BRANCH_NAME}-${BUILD_ID}"
                            }
                        }
                    }
                }
            """
            def response = httpRequest acceptType: 'APPLICATION_JSON', contentType: 'APPLICATION_JSON', httpMode: 'POST', requestBody: patchOrg, url: "http://deployer-kuber-deployer.kube-system"
            def jsonObj = readJSON text: response.content
            echo jsonObj['result']
        }
        stage('Functional Test') {
            container('selenium') {
                try {
                    sh 'pytest /app --verbose --junit-xml reports/tests.xml'
                } finally {
                    junit testResults: 'reports/tests.xml'
                    echo "http://zalenium.35.246.75.225.nip.io/dashboard/?q=build:kuber-${BRANCH_NAME}-${BUILD_ID}"
                }
            }
        }
    }
}
