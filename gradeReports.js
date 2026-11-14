import * as XLSX from 'xlsx';
import {PDFDocument, StandardFonts, rgb} from 'pdf-lib';

// A report always contains one selected class and one selected subject.
export async function buildGradeReport(format, report) {
 const {className, subject, teacher, rows}=report;
 const headers=['Nama siswa','Kelas','Mata pelajaran','Tugas','Nilai (0–100)','Keterangan'];
 if(format==='Excel') {
  const sheet=XLSX.utils.aoa_to_sheet([
   ['REKAP NILAI KARSA - DATA DEMO'],['Kelas',className],['Mata pelajaran',subject],['Guru',teacher],
   ['Data lokal, bukan nilai resmi. Nilai kosong berarti belum ada nilai.'],[],headers,
   ...rows.map(r=>[r.name,className,subject,r.task,r.grade===null?null:r.grade,r.note])
  ]);
  sheet['!cols']=[{wch:25},{wch:12},{wch:32},{wch:42},{wch:18},{wch:40}];
  const book=XLSX.utils.book_new();XLSX.utils.book_append_sheet(book,sheet,'Rekap Nilai');
  return XLSX.write(book,{type:'base64',bookType:'xlsx'});
 }
 if(format!=='PDF') throw new Error('Format ekspor tidak dikenal.');
 const doc=await PDFDocument.create(), font=await doc.embedFont(StandardFonts.Helvetica), bold=await doc.embedFont(StandardFonts.HelveticaBold);
 const clean=value=>String(value??'').replace(/[^\x20-\x7e\xa0-\xff]/g,'-');
 const wrap=(value,width,size)=>{const text=clean(value);const lines=[];let current='';for(const word of text.split(/\s+/)){let pending=word;while(pending){const candidate=current?current+' '+pending:pending;if(font.widthOfTextAtSize(candidate,size)<=width){current=candidate;pending='';continue}if(current){lines.push(current);current='';continue}let n=pending.length;while(n>1&&font.widthOfTextAtSize(pending.slice(0,n),size)>width)n--;lines.push(pending.slice(0,n));pending=pending.slice(n)}}if(current||!lines.length)lines.push(current);return lines};
 let page,y;const line=(text,x,size=9,face=font)=>page.drawText(clean(text),{x,y,size,font:face,color:rgb(.15,.18,.23)});
 const newPage=()=>{page=doc.addPage([842,595]);y=565;line('REKAP NILAI KARSA - DATA DEMO',30,15,bold);y-=23;line(`Kelas: ${className}    Mata pelajaran: ${subject}    Guru: ${teacher}`,30,10);y-=16;line('Data lokal, bukan nilai resmi. Nilai kosong berarti belum ada nilai.',30,9);y-=24;line('Nama siswa',30,9,bold);line('Tugas',210,9,bold);line('Nilai',530,9,bold);line('Keterangan',590,9,bold);y-=15;page.drawLine({start:{x:30,y:y+5},end:{x:812,y:y+5},thickness:.5,color:rgb(.7,.7,.7)});};
 newPage();if(!rows.length){line('Belum ada tugas pada kelas dan mata pelajaran ini.',30);}
 rows.forEach(r=>{const cols=[wrap(r.name,170,9),wrap(r.task,310,9),[r.grade===null?'-':String(r.grade)],wrap(r.note,220,9)];const count=Math.max(...cols.map(c=>c.length));for(let i=0;i<count;i++){if(y<35)newPage();[30,210,530,590].forEach((x,j)=>{if(cols[j][i])line(cols[j][i],x)});y-=13}y-=4});
 return doc.saveAsBase64();
}
