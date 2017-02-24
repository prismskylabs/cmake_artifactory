import sys
import py_artifactory
#CLI functions to work with simplified artifactory structure


def find_artifact(repo,project,platform,version):
    try:
        items = py_artifactory.findArtifact(repo,project,platform,version)
        for item in items:
            sys.stdout.write(str(item)+"\n")
    except Exception as e:
        sys.stderr.write(str(e))
        exit(1)
    except:
        sys.stderr.write(str(sys.exc_info()[0]))
        exit(1)

def get_artifact(repo,project,platform,version,localPath):
    try:
        py_artifactory.getArtifact(repo,project,platform,version,localPath)
        sys.stdout.write(str(localPath)+"\n")
    except Exception as e:
        sys.stderr.write(str(e))
        exit(1)
    except:
        sys.stderr.write(str(sys.exc_info()[0]))
        exit(1)
            
def put_artifact(localPath,repo,project,platform):
    try:
        py_artifactory.putArtifact(localPath,repo,project,platform)
    except Exception as e:
        sys.stderr.write(str(e))
        exit(1)
    except:
        sys.stderr.write(str(sys.exc_info()[0]))
        exit(1)
