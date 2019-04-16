import scipy.io
from pathlib import Path

pythonFolder = Path.cwd()
analysisFolder = Path(pythonFolder).resolve().parent
dataFolder = Path(analysisFolder / 'EyeMovementAnalysisCode/analysis')
# print(dataFolder)
