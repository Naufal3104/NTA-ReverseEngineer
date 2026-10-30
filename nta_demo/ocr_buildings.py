from rapidocr_onnxruntime import RapidOCR
import glob, os
engine = RapidOCR()
d = r'D:\Android\NTA Project Reverse Engineering\Building-20261024T130202Z-1-001\Building'
fs = sorted(glob.glob(d + '\\*.jpg'))
out = []
for i, f in enumerate(fs):
    res, _ = engine(os.path.normpath(f))
    txts = [t[1] for t in (res or [])]
    block = '===== FILE %02d: %s =====\n' % (i, os.path.basename(f)) + '\n'.join(txts)
    out.append(block)
open(r'D:\Android\NTA Project Reverse Engineering\nta_demo\building_ocr.txt', 'w', encoding='utf-8').write('\n\n'.join(out))
print('WROTE', len(out), 'files')
