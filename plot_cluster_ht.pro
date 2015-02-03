pro plot_cluster_ht, dir=dir, tog=tog, n_clusters=n_clusters

;dir = '20000101'
;xls = anytim('2000-01-01T12:53:07',/ccsds)
;xrs = anytim('2000-01-03T08:30:00',/ccsds)
;txt_fl = 'cme_kins_savgol_20000101_145225.txt'

dir = '20010423'
xls = anytim('2001-04-23T06:40:08',/ccsds)
xrs = anytim('2001-04-24T17:59:59',/ccsds)
txt_fl = 'cme_kins_savgol_20010423_081609.txt'

; How many clusters?
if n_elements(n_clusters) eq 0 then n_clusters = 4

if n_elements(dir) eq 0 then dir = '20000101'

; *************
; If reading in the cme_kin_prof sav files:
goto, skip1

no = '00'
fls=file_search('../'+dir+'/cme_profs/cme_kin_profs/cme_kin_prof_'+no+'_*sav')

; Clean
goto, skip1
for i=0,n_elements(fls)-1 do begin
        restore, fls[i] ; definite_x, definite_y, datetime
        if i eq 0 then begin
                definite_xs = definite_x
                definite_ys = definite_y
                datetimes = datetime
                pos_angles = replicate(fix(strmid(file_basename(fls[i]),20,3)),n_elements(definite_x))
        endif else begin
                definite_xs = [definite_xs, definite_x]
                definite_ys = [definite_ys, definite_y]
                datetimes = [datetimes, datetime]
                pos_angles = [pos_angles, replicate(fix(strmid(file_basename(fls[i]),20,3)),n_elements(definite_x))]
        endelse
endfor
utplot, datetimes, definite_ys, psym=3
;pause
skip1:

;goto, skip1
; *************
; If reading in the kinematic text file:
no = 'txt'
fl_txt = file_search('../'+dir+'/cme_kins/'+txt_fl)
readcol, fl_txt, date_txt, time_txt, heights_txt, pos_angles_txt, f=('A,A,D,F')
datetimes_txt = date_txt+' '+time_txt
definite_ys_txt = heights_txt
definite_xs_txt = indgen(n_elements(datetimes_txt))
utplot, datetimes_txt, heights_txt, psym=3
;pause
;skip1:
; CLEAN
datetimes = datetimes_txt
definite_ys = definite_ys_txt
definite_xs = definite_xs_txt
pos_angles = pos_angles_txt
clean_heights, datetimes, definite_ys, pos_angles

ind = uniq(pos_angles)
for i=0,n_elements(ind)-1 do begin & $
        inds = where(pos_angles eq pos_angles[ind[i]]) & $
        angs = pos_angles[inds] & $
        definite_x = definite_xs[inds] & $
        definite_y = definite_ys[inds] & $
        datetime = datetimes[inds] & $
        if i gt 99 then label = int2str(i) & $
        if i lt 100 then label = '0'+int2str(i) & $
        if i lt 10 then label = '00'+int2str(i) & $
        if i eq 0 then begin & $
                if dir_exist('../'+dir+'/cme_profs_clean') then spawn, 'rm -rf ../'+dir+'/cme_profs_clean' & $
                spawn, 'mkdir -p ../'+dir+'/cme_profs_clean' & $
        endif & $
        save, definite_x, definite_y, datetime, f='../'+dir+'/cme_profs_clean/cme_kins_prof_'+no+'_'+label+'_'+int2str(angs[0])+'.sav' & $
endfor

fls = file_search('../'+dir+'/cme_profs_clean/cme_kins_prof_'+no+'_*sav')

if dir_exist('../'+dir+'/clustering_out_dir') eq 1 then spawn, 'rm -rf ../'+dir+'/clustering_out_dir'
spawn, 'mkdir -p ../'+dir+'/clustering_out_dir'
group_cme_kins, fls, n_clusters=n_clusters, out_dir='../'+dir+'/clustering_out_dir', tog=tog

;utplot, 0, 0, yr=[0,25000], xr=[xls,xrs], /nodata

time = anytim(datetimes)
utbasedata = min(time)
t = time-utbasedata
rsun = (pb0r(datetimes[0],/arcsec,/soho))[2]
km_arc = 6.955e8 / (1000.*rsun)

cluster_savs = file_search('../'+dir+'/clustering_out_dir/cluster*sav')
for i=0,n_elements(cluster_savs)-1 do begin & $
        restore, cluster_savs[i], /ver & $
        for j=0,n_elements(cluster_inds)-1 do begin & $
                restore, fls[cluster_inds[j]], /ver & $
                if i eq 0 && j eq 0 then utplot, anytim(datetime)-utbasedata, (definite_y*km_arc)/1000., utbasedata, xr=[xls,xrs], yr=[0,2e4], psym=3, color=((i+2) mod 7) & $
                if n_elements(definite_y) gt 1 then outplot, anytim(datetime)-utbasedata, (definite_y*km_arc)/1000., utbasedata, psym=3, color=((i+2) mod 7) & $
        endfor & $
pause & $
endfor
heights_km = definite_y*km_arc

if keyword_set(tog) then begin
        set_plot, 'ps'
        loadct, 13
        device, /encapsul, bits=8, language=2, /portrait, /color, filename='../'+dir+'/cluster_plot_ht_'+no+'.eps', xs=20, ys=30
        !p.background = 1
        !p.charsize = 1.0
        !p.charthick = 5
        !p.thick = 3
        !x.thick = 3
        !y.thick = 3
        plot_char = 1
        y_range = [0,2.e4]
        utplot, 0,0, yr=y_range, xr=[xls,xrs], $
                ytit='Height (Mm)', /xs, ystyle=8, /nodata, pos=[0.15,0.63,0.92,0.91]
        axis, yaxis=1, yrange=y_range/695.5, /ys, ytit='R!D!9n!N!X'
        ; plot all the original data
        rsun = (pb0r(datetimes_txt[0],/soho,/arcsec))[2]
        km_arc = 6.955e8 / (1000.*rsun)
        heights_km = definite_ys_txt * km_arc
        ;outplot, datetimes_txt, heights_km/1000., psym=3

        ; plot the clustered data
        cluster_savs = file_search('../'+dir+'/clustering_out_dir/cluster*sav')
        for i=0,n_elements(cluster_savs)-1 do begin
                restore, cluster_savs[i], /ver
                for j=0,n_elements(cluster_inds)-1 do begin
                        restore, fls[cluster_inds[j]], /ver
                        t = datetime
                        time = anytim(t)
                        utbasedata = min(time)
                        rsun = fltarr(n_elements(datetime))
                        for k=0L,n_elements(rsun)-1 do rsun[k] = (pb0r(datetime[k],/soho,/arcsec))[2]
                        km_arc = 6.955e8 / (1000.*rsun)
                        heights_km = fltarr(n_elements(definite_y))
                        for k=0L,n_elements(definite_y)-1 do heights_km[k] = definite_y[k]*km_arc[k]
                        set_line_color
                        outplot, datetime, heights_km/1000., psym=([1,4,5,6,7,8,9])[i], color=([3,5,4,6,7,8,9])[i]
                        horline, 2.2*695.5, linestyle=1
                        horline, 6.*695.5, linestyle=1
                        horline, 25*695.5, linestyle=1
                endfor
        endfor



        device, /close_file
        set_plot, 'x'
endif

end
                                                              
