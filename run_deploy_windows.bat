"C:\Program Files\Git\bin\bash.exe" -c "curl -u jenkins:jenkins -T target/**.war 'http://localhost:8083/manager/text/deploy?path=/devops&update=true'"
