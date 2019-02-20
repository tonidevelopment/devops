node {
	def mvnHome
	def pom
	def artifactVersion
	def tagVersion
	def retrieveArtifact
	
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
   }
   stage('Deploy') {
     bat ('run_deploy_windows.bat')    

   }

	 stage("Smoke Test"){
     bat ('run_test_windows.bat')    
   }
}
