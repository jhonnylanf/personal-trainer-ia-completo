from pathlib import Path
import re,sys
p=Path(sys.argv[1]);s=p.read_text(encoding='utf-8',errors='ignore')
s=re.sub(r'(?i)Max Treino Pro|Treino Inteligente IA|Personal IA','Personal Trainer IA',s)
marker='''<script id="flutter-native-bridge">(function(){function send(x){if(window.AndroidBridge)AndroidBridge.postMessage(JSON.stringify(x));}window.AndroidRestTimer=window.AndroidRestTimer||{scheduleAt:function(t){send({type:'scheduleRest',endAt:Number(t)});},schedule:function(s){send({type:'scheduleRest',endAt:Date.now()+Number(s)*1000});},cancel:function(){send({type:'cancelRest'});}};})();</script>'''
pos=s.lower().rfind('</body>');s=s[:pos]+marker+s[pos:] if pos>=0 else s+marker
p.write_text(s,encoding='utf-8')
print('bytes',p.stat().st_size)
