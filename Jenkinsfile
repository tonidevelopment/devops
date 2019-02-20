node {
	def mvnHome
	def pom
	def artifactVersion
	def tagVersion
	def retrieveArtifact
	def tomcatUrl
	
	stage('Prepare') {
       mvnHome = tool 'maven'
	}
	
	stage('Checkout') {
     checkout scm
	}
	
	stage('Build') {
      if (isUnix()) {
         sh "'${mvnHome}/bin/mvn' -Dmaven.test.failure.ignore clean package"
      } else {
         bat(/"${mvnHome}\bin\mvn" -Dmaven.test.failure.ignore clean package/)
      }
	}
	
	stage('Unit Test') {
      junit '**/target/surefire-reports/TEST-*.xml'
      archiveArtifacts artifacts: ' **/*.jar'
	}
	
	stage('Integration Test') {
     if (isUnix()) {
        sh "'${mvnHome}/bin/mvn' -Dmaven.test.failure.ignore clean verify"
     } else {
        bat(/"${mvnHome}\bin\mvn" -Dmaven.test.failure.ignore clean verify/)
     }
	}
	
   stage('Sonar') {
      if (isUnix()) {
         sh "'${mvnHome}/bin/mvn' sonar:sonar"
      } else {
         bat(/"${mvnHome}\bin\mvn" sonar:sonar/)
      }
   }
   
   if(env.BRANCH_NAME == 'master'){
    stage('Validate Build Post Prod Release') {
      if (isUnix()) {
         sh "'${mvnHome}/bin/mvn' clean package"
      } else {
         bat(/"${mvnHome}\bin\mvn" clean package/)
      }
    }
  }

  if(env.BRANCH_NAME == 'develop'){
	    stage('Snapshot Build And Upload Artifacts') {
	      if (isUnix()) {
	         sh "'${mvnHome}/bin/mvn' clean deploy"
	      } else {
	         bat(/"${mvnHome}\bin\mvn" clean deploy/)
	      }
	    }
   
	   stage('Deploy') {
	     bat ('run_deploy_windows.bat')    
	
	   }
	
		 stage("Smoke Test"){
	     bat ('run_test_windows.bat')    
	   }
   }
    if(env.BRANCH_NAME ==~ /release.*/){
        pom = readMavenPom file: 'pom.xml'
        artifactVersion = pom.version.replace("-SNAPSHOT", "")
        tagVersion = artifactVersion

        stage('Release Build And Upload Artifacts') {
          if (isUnix()) {
             sh "'${mvnHome}/bin/mvn' clean release:clean release:prepare release:perform"
          } else {
             bat(/"${mvnHome}\bin\mvn" clean release:clean release:prepare release:perform/)
          }
        }
         stage('Deploy To Dev') {
           bat ('run_deploy_windows.bat')   
         }

         stage("Smoke Test Dev"){
             bat ('run_test_windows.bat')    
         }

         stage("QA Approval"){
             echo "Job '${env.JOB_NAME}' (${env.BUILD_NUMBER}) is waiting for input. Please go to ${env.BUILD_URL}."
             input 'Approval for QA Deploy?';
         }

         stage("Deploy from Artifactory to QA"){
           retrieveArtifact = 'http://localhost:8081/artifactory/libs-release-local/com/example/devops/' + artifactVersion + '/devops-' + artifactVersion + '.war'
           tomcatUrl = 'http://localhost:8083/manager/text/deploy?path=/devops&update=true'
           
           echo "${tagVersion} with artifact version ${artifactVersion}"
           echo "Deploying war from http://localhost:8081/artifactory/libs-release-local/com/example/devops/${artifactVersion}/devops-${artifactVersion}.war"
           bat('curl -u admin:5E7gbTBjHJIx -O ' + retrieveArtifact)
           bat ('run_deploy_from_Artifactory_to_QA_windows.bat')   
         }

      }

}