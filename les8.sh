#!/bin/bash
touch /opt/str_file
file=/opt/str_file
lockfile=/tmp/localfile
function myfunc {
echo -e "Дата запуска скрипта: `date`.\nСкрипт обработал $time_1 $time_2. \n";
echo -e "X: IP с наибольшим колич-вом запросов: \n$x_ip";
echo -e "Y: С наибольшим колич-вом адресов: \n$y_adr";
echo -e "Z: Только ошибки: \n$z_err";
echo -e "W: Все коды: \n$w_code";
echo -e "Винимание! Если пустые строки, значит нет новых записей.\n"
}
function myfunc2 {
if [[ -s $file ]]
then
str=$(cat $file)
x_ip=`sed '1,'$str'd' /vagrant/access-4560-644067.log | cut -d ' ' -f1 | sort | uniq -c | sort -rh | head`
y_adr=`sed '1,'$str'd' /vagrant/access-4560-644067.log | cut -d ' ' -f7 | sort | uniq -c | sort -rh | head | sed -e '2,$s/\///; s/400/Ошибка 400/'`
z_err=`sed '1,'$str'd' /vagrant/access-4560-644067.log | cut -d ' ' -f9 | sort | uniq -c | sort -rh | egrep '(4|5)[0-9][0-9]$' | head `
w_code=`sed '1,'$str'd' /vagrant/access-4560-644067.log | cut -d ' ' -f9 | sort | uniq -c | sort -rh `
time_1=`sed '1,'$str'd' /vagrant/access-4560-644067.log | head -1 | cut -d " " -f 4 | sed  's/\[/C /'`
time_2=`sed '1,'$str'd' /vagrant/access-4560-644067.log | tail -1 | cut -d " " -f 4 | sed  's/\[/По /'`
echo `wc -l /vagrant/access-4560-644067.log | cut -d ' ' -f1` > $file
myfunc | mail -S sendwait -s "Log lesson8" root@localhost
else
x_ip=`cut -d ' ' -f1 /vagrant/access-4560-644067.log | sort | uniq -c | sort -rh | head`
y_adr=`cut -d ' ' -f7 /vagrant/access-4560-644067.log | sort | uniq -c | sort -rh | head| sed -e '2,$s/\///; s/400/Ошибка 400/'`
z_err=`cut -d ' ' -f9 /vagrant/access-4560-644067.log | sort | uniq -c | sort -rh | egrep '(4|5)[0-9][0-9]$' | head`
w_code=`cut -d ' ' -f9 /vagrant/access-4560-644067.log | sort | uniq -c | sort -rh `
time_1=`head -1 access-4560-644067.log | cut -d " " -f 4 | sed  's/\[/C /'`
time_2=`tail -1 access-4560-644067.log | cut -d " " -f 4 | sed  's/\[/По /'`
myfunc | mail -S sendwait -s "Log lesson8" root@localhost
echo `wc -l /vagrant/access-4560-644067.log|cut -d ' ' -f1`> $file
fi
}

if (set -o noclobber; echo "$$" > "$lockfile") 2> /dev/null;
then
myfunc2
trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT
rm -f "$lockfile"
trap - INT TERM EXIT
else
   echo "Failed to acquire lockfile: $lockfile."
   echo "Held by $(cat $lockfile)"
fi

