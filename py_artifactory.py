import fnmatch
from artifactory import ArtifactoryPath

def findArtifact(repo,project,platform,version):
    artifactPath = repo+"/"+project+"/"+platform+"/"
    path = ArtifactoryPath(artifactPath)  
    foundItems = list(filter(lambda p: fnmatch.fnmatch(str(p),'*/{}_{}*.tar.gz'.format(project,version)), path))
    return foundItems

def getArtifact(repo,project,platform,version,localPath):
    artifactPath = repo+"/"+project+"/"+platform+"/"
    path = ArtifactoryPath(artifactPath)  
    foundItems = list(filter(lambda p: fnmatch.fnmatch(str(p),'*/{}_{}*.tar.gz'.format(project,version)), path))
    if len(foundItems)==0:
        raise Exception('No matching artifacts found')
    if len(foundItems)>1:
        raise Exception('Too many matching artifacts found. Version is not unique. Found {}'.format(str(foundItems)))
    with foundItems[0].open() as fd:
        with open(localPath, "wb") as out:
            out.write(fd.read())
            
def putArtifact(localPath,repo,project,platform):
    artifactPath = repo+"/"+project+"/"+platform+"/"
    path = ArtifactoryPath(artifactPath)
    if not path.exists():
        path.mkdir()
    path.deploy_file(localPath)
