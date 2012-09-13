;
;###################################################################################
;	AutoLisp
;	������ ��� ��������
;	������� �����, ���������� � �������, ���������� � ����� � �.�.
;	��� �������� ������� � ���������� �������� ��������� X/2-Z.
;	��� ������� ��������� � �� ����������� ������������ X-Z.
;###################################################################################
;	���������� ��� ������������ ������������ ������������ ����:
;	acad_asix = {	
;			"x/2-z" 	- ��� �������� �������		
;			"x-z"		-  ��� ��������� � ���������
;			}
;###################################################################################
;	������� ������
;	gerasev.kirill@gmail.com
;	25/04/2012
;###################################################################################
;		 ������� ������:
;
;		 find_real_coord ( list_of_coord  acad_axis ) => list_of_coord
;		 revers_order_of_coord( list_of_coord ) => list_of_coord
;		 mk_difference ( list_of_coord ) => list_of_coord 
;		 bubltoarc ( pt1 pt2 bubl ) => ( cnt r (angle cnt pt1) (angle cnt pt2) )
;		 debug (text debug_info)
; 		 draw_point_and_text ( list_of_coord ) 
;  		 print_to_table( list_of_coord title acad_axis )
;		 coord_to_string( n_t ) => ( string )
;

;###################################################################################
; ����� ��� ���� ��������
;

;;;;;;;;;;;;;;;; ����� � ������ �� �������
(defun min1(f)
 (cond 
  ((null f) nil)
  (1 (min2 (car f) (cdr f)))
 )
)

(defun min2(c f)
 (cond 
  ((null f) c)
  ((> c (car f)) (min2 (car f) (cdr f)))
  (1 (min2 c (cdr f)))
 )
)

(defun remov(c f)
 (cond 
  ((null f) nil)
  ((= c (car f)) (cdr f))
  (1 (cons (car f) (remov c (cdr f))))
 )
)


(defun sort_int(f)
 (cond
   ((null f) nil)
   (1 (cons (min1 f) (sort_int (remov (min1 f) f))))
  )
)

;;;;;;;;;;;;;;;;;;

(defun real_X_Y(coord acad_axis / _realX _realY _res) ; ����������� ������ � ��������� ������������
	(if (= acad_axis "x/2-z")
		(progn	; ��� �������� �������
			(setq _realX (nth 1 coord))
			(setq _realX (* -1 coord))
			(setq _realY (car coord))
			(list (list _realX _realY))
		)
		(	;��� ��������� � ���������
			(setq _res coord)
		)
	)
)

(defun find_real_coord (list_of_coord  acad_axis /  ; ����� �������� ���������� ��� �������
							_res  _tmp  _realX  _realY) 
	(if (= acad_axis "x/2-z");���� �������� ������, ��
		(progn
			(setq	_res NIL)
			( foreach _tmp list_of_coord
				(setq _realX (nth 1 _tmp))
				(setq _realX (* -1 _realX))
				(setq _realY (car _tmp))
				(if (> (LENGTH _tmp) 2)
					(setq _res ( append _res (list (list _realX _realY (nth 2 _tmp)))))
					(setq _res ( append _res (list (list _realX _realY))))
				)
			)
		)
		; ����� ������� ���� ��� � ����
		(setq _res list_of_coord)
	)
)

(defun revers_order_of_coord(list_of_coord / _res _n) 	; �������� ���������� ��������� �����
	(setq _res NIL)
	(setq _n  (LENGTH list_of_coord))
	(while (/= _n 0)
		(setq _n (1- _n ))
		(setq _res (append _res (list (nth _n list_of_coord))))
	)
)

(defun mk_difference (list_of_coord / _dif  _last_coord  _X  _Y _tmp_coord) ; �����������  ������������� ���������
	; �� ����� ������ ���������
	(setq	_dif NIL)
	; ��������� ������������ 1 ����� � ������
	(setq _last_coord (car list_of_coord))
	(foreach _tmp list_of_coord 
		(setq _X ( - (car _tmp) (car _last_coord)))
		(setq _Y ( - (nth 1 _tmp) (nth 1 _last_coord) ))
		(setq _last_coord _tmp)
		(if (> (LENGTH _tmp) 2)
				; ��� ���
			(setq _dif ( append _dif (list (list _X _Y (nth 2 _tmp)))))
			(setq _dif ( append _dif (list (list _X _Y))))
		)
	)
)

(defun from_object_to_coord(object /  _n _lst_point _res _tmp ) ; ����������� ��������� �� �������� ���� �����, �����, ���������
	(setq _lst_point NIL)
	(setq _n 0)
	(while ( <  (+ _n 3) (LENGTH object)); ���������
		(setq _tmp (nth _n object))
		(if (= ( car _tmp) 10 )  
			(progn;;;;;;;;;;;;;;;;;
				(if (/= (cdr (nth (+ _n 3) object )) 0 )
					(setq _lst_point (append _lst_point (list ( list (round (nth 1 _tmp) 3)  (round (nth 2 _tmp)  3) (cdr (nth (+ _n 3) object ))	))))
					(setq _lst_point (append _lst_point (list ( list (round (nth 1 _tmp)  3) (round (nth 2 _tmp) 3)))))
				)
			)
		)
		(setq _n (1+ _n))
	)
	(if (< (LENGTH object) 20); �����
		(progn
			(foreach _tmp object
				(if (= (car _tmp ) 10)
					(setq _lst_point (append _lst_point (list ( list (round (nth 1 _tmp) 3) (round (nth 2 _tmp) 3)))))
				)
				(if (= (car _tmp ) 11)
						(setq _lst_point (append _lst_point (list ( list (round (nth 1 _tmp) 3) (round (nth 2 _tmp) 3)))))
				)
			)
		)
	)
	(setq _res _lst_point)
)

;;;;;;;;;;;;;;;;; ����� � ������ �� �������
(defun bubltoarc (pt1 pt2 bubl / dst cnt r); ��������� ������������� ���� �� polyline � arc.
  ;��������� �����, ��������, �������� 42 ������
	(setq 	dst (distance pt1 pt2)
		r	(+ (* (/ dst 2.0) bubl) (/ (- (* (/ dst 2.0) (/ dst 2.0))
			(* (/ (* dst bubl) 2.0) (/ (* dst bubl) 2.0))) (* dst bubl)))
		cnt	(polar
			(polar pt1 (angle pt1 pt2) (/ dst 2.0))
			(- (angle pt1 pt2) (/ pi 2.0))
			(- (* (/ dst 2.0) bubl) r))
	);end of setq
	(list cnt r (angle cnt pt1) (angle cnt pt2))
  ; �� ������:
  ; ����� ������ ����, ������, ���������� ���� ����, ��������� ���� ����
)
;;;;;;;;;;;;;;;;;

(defun get_current_layer( / _res)
	(setq _res (getvar "CLAYER" ))
	(if (= (substr _res 1 2) "T-")
		(setq _res (list _res  (substr _res 3 2)))
	)
)

(defun is_T(layers / _res _T_lay) ; �������� �� ���� ����� � ���������� ������� �������� �����������
	(setq _T_lay nil)
	(foreach lay layers
		(if (= (substr lay 1 2) "T-")
			(setq _T_lay (append _T_lay (list lay)))
		)
	)
	(setq _res _T_lay)
)

(defun copy_to_layer (layer_name weigth /  _material _weigth _res ); ����������� �� ���� �������� � ���� � ������ layer_name
	; FiXME ������� ����� ���������� �� �������
	(setq _material (ssget "_w" (list  -200  -200) (list  200 200)))
	(command "_copytolayer" _material "" layer_name (list 0 0) (list 0 weigth))
	(princ)
)

(defun get_date ( / d yr mo day) ; ��������� ����.
     (setq date (rtos (getvar "CDATE") 2 6)
     (setq year (substr date 3 2))
     (setq months (substr date 5 2)
     (setq day (substr d 7 2)))
     (strcat day "." months "." year)
)

(defun get_all_info( / _operation _modification _name   _full_path _res _res1)
	; ��������� ���������� �� �������� �����. �������� ������������ ������� ������ ����:
	;root/���_������/�����_������_�_�����_�������/��������
	;FIXME: 	�������� �� ���� ��������� ��������� ������������ ������
	(setq _full_path (GETVAR "dwgprefix"))
	(setq _operation (get_last_folder _full_path))
	(setq _modification (get_last_folder (last _operation)))
	(setq _name (get_last_folder (last _modification)))
	(setq _res (list
				(car _name)
				(car _modification)
				(car _operation)
	))
)

(defun get_last_folder( folder_name /  _i  _res   _tmp  )
	; ������� ��� ����������� ������������ ����� � ����� ��������� ����� � ������
	; ������ ��� WINDOWS
	; FIXME: 	������������� ��� LINUX
	; ������������: 1-��� �����; 2-���� � ������������ �����
	(setq _i (- (strlen folder_name) 1))
	(while (> _i 0)
		(setq _tmp (substr folder_name _i 1))
		(if (= _tmp "\\")
			(progn
				(setq _res _i)
				(setq _i  -1)
			)				
		)
		(setq _i (- _i 1))
	)
	(setq  _res1 (+ _res 1))
	(setq _res (list (substr folder_name  _res1  ( - (strlen folder_name) _res1) )))
	(setq _res (append _res (list (substr folder_name 1  (- _res1 1)))))
)

(defun get_dwg_name( / _folder_name _i  _tmp  _res)
	(setq _folder_name (GETVAR "dwgprefix"))
	(setq _res (get_last_folder _folder_name))
)

(defun get_layers_names( / _ln  _layers _res)
	(vl-load-com)
	(vlax-for layer (vla-get-layers (vla-get-activedocument (vlax-get-acad-object)))
	(vl-catch-all-apply
	      (function
		(lambda ()
		  (setq _ln (vla-get-name layer))
		)
	      )
	)
	; � ������ ������������ ��� ���� �����  Defpoints � 0
	(if (not (or (equal _ln "Defpoints") (equal  _ln "0")))
		(setq _layers (append _layers (list _ln)))
	)
  )
  (setq _res _layers)
)


;###################################################################################
; ��������������� ������� ������ � ���������

(defun debug (text debug_info) ; ����� ���������� ����������
	(princ "\n")
	(princ text)
	(princ " : ")
	(princ debug_info)
	(princ "\n")
)

(defun draw_all(_lst_point index  acad_axis /  _rev_order _res _sys_var); ��������� ������� � ����� �� ������ ���������
	; ������ ���������, ������ � �������� ���������� ������ ���������, ���.
	; 
	(setq _sys_var (mapcar 'getvar '("osmode" "cmdecho")))
	(setvar "osmode" 0)
	(setvar "cmdecho" 0)
	;;;;;;;
	
	(setq  _lst_point (find_real_coord _lst_point acad_axis))
	(setq GK_LIST_OF_COORD _lst_point)
	(if (> (nth 1 (car _lst_point))	(nth 1 (last _lst_point)))
		(setq GK_ORDER "right")
		(setq GK_ORDER "left")  
	)
	(draw_point_and_text 	_lst_point 	 acad_axis   index)
	(setq _rev_order 0)
	(setq answ (getstring "\n������� �������� ������� �����? <�/�>"))
	(if ( OR ( = answ "�" ) ( = answ "�" ) )
		(progn
			(command "��������"  1)
			(setq _lst_point (revers_order_of_coord _lst_point))
			(draw_point_and_text _lst_point		acad_axis   index)
			(setq _rev_order 1)
			(setq GK_LIST_OF_COORD _lst_point)
		)
	)
	(setq GK_ABSOLUTE 1)
	
	;;;;;;;
	(mapcar 'setvar '("osmode" "cmdecho") sys_var)
	(setq _res (list _rev_order _lst_point))
)

(defun draw_point_and_text (list_of_coord  acad_axis  index / _n  _undo_tmp _angle_of_text)
	; ��������� ������� � ����� �� ������ ���������
	; ������ ���������, ������ � �������� ���������� ������ ���������, ���.
	; 
	(vla-startundomark
		(setq _undo_tmp (vla-get-activedocument (vlax-get-acad-object)))
    ) ; ������ ����������� ������
	;FIXME: �� bricscad (12 ��� Linux) �� ��������=(
	
	(setq _n index)
	(command "_color" GK_COLOR)
	(if (= acad_axis "x/2-z")
		(setq _angle_of_text 90)
		(setq _angle_of_text 0)
	)
	(foreach _tmp list_of_coord
		(command "�����" (list (car _tmp) (nth 1 _tmp)))
		; FIXME:����������� _text �� ���������� � ������������ � ������.
		(command "_text" (polar (list (car _tmp) (nth 1 _tmp)) (/ pi 4) 2) _angle_of_text (rtos _n 2))
;		(if  (> (LENGTH _tmp) 2)
;				(command "_text" (polar (list (car _tmp) (nth 1 _tmp)) (/ pi 4) 6) _angle_of_text (nth 2 _tmp))			
;		)
		(setq _n (1+ _n))
	)
	(command "_color" "_BYLAYER")
	(vla-endundomark _undo_tmp) ; ����� ������� 
)

(defun draw_circle_and_text (list_of_coord 	radius	index  acad_axis  side / _n  _undo_tmp _angle_of_text _tmp_fake)
	;  ������� ��� ����������� ����������� �������� radius ������ ������� �����. 
	;  ����� ������������� ����� �� ���� ����������
	;  ����� �� ����� �������������, ���� �������� �� ����� � ��������� 1...4
	;  ����.
	;	draw_circle_and_text (list 0 0) 8 0 "axis" 4	<= 	"4" - ��������, ��� ����� ����� ������������� � 4 ��������
	;	FiXME:		"axis" - ���� ��������� ����������
	;	��� �������� 0 ������������� ������ �� �����
	;									--
	;							--	       --
	;					 --						 �
	;							--			--
	;									�
	;
	(vla-startundomark
		(setq _undo_tmp (vla-get-activedocument (vlax-get-acad-object)))
	) ; ������ ����������� ������
	; �� bricscad "vla-startundomark" (12 ��� Linux) �� ��������=(
	(command "_color" GK_COLOR )
	(setq _n index)
	(if (= acad_axis "x/2-z")
		(setq _angle_of_text 90)
		(setq _angle_of_text 0)
	)
	(foreach _tmp list_of_coord
		(command "����" (list (car _tmp) (nth 1 _tmp)) radius)
		(command "_text" (polar (list (car _tmp) (nth 1 _tmp)) (/ pi 4) 2) _angle_of_text (rtos _n 2))
;		(if  (> (LENGTH _tmp) 2)
;				(command "_text" (polar (list (car _tmp) (nth 1 _tmp)) (/ pi 4) 6) _angle_of_text (nth 2 _tmp))			
;		)
		(setq _n (1+ _n))
		(cond 
			((= side 1) ; ������ ��������
				(command "�����"  (list (car _tmp) (+ (nth 1 _tmp) radius)) )
				(command "�����" (list (- (car _tmp) radius) (nth 1 _tmp)))
			)
			((= side 2) ; ������ ��������
				(command "�����" (list (car _tmp) (- (nth 1 _tmp) radius)))
				(command "�����" (list (- (car _tmp) radius) (nth 1 _tmp)))
			)
			((= side 3) ;  3 ��������
				(command "�����" (list (car _tmp) (- (nth 1 _tmp) radius)))
				(command "�����" (list (+ (car _tmp) radius) (nth 1 _tmp)))
			)
			((= side 4) ; 4 ��������
				(command "�����" (list (car _tmp) (+ (nth 1 _tmp) radius)))
				(command "�����" (list (+ (car _tmp) radius) (nth 1 _tmp)))
			)		
		)
	)
	(command "_color" "_BYLAYER")
	(vla-endundomark _undo_tmp) ; ����� ������� 
)

(defun get_font_size( / _text_style 	_text_size_s		_res)
	; ����������� ������� ������ �� �������� �������� �����
	; ����: 	"�� ���� 3" => 3
	; FIXME:		���������� ���, ���� �� ���� ���� ��������� ���� ������ ������ � ����� �����
	(setq _text_style (getvar "TEXTSTYLE"))
	(setq _text_size_s (substr _text_style
						(strlen _text_style)
				))
	(setq _res (atoi _text_size_s ))
)

(defun round (var to / _res)
		; ������� ����������
		; ������ �� ������ �� �����%)
		(setq _res (rtos var 2 to ))
		(setq _res (atof _res))
) 

(defun print_to_table(list_of_coord   title    acad_axis index / _model_space  _pt  _n  _X  _Y		_font_size)	; ������ � �������
	(vl-load-com)
	(setq _model_space (vla-get-Modelspace(vla-get-ActiveDocument(vlax-get-acad-object))))  
	; �� bricscad (12 ��� Linux) �� ��������  (vla-get-ActiveDocument(vlax-get-acad-object))
	(setq _pt (getpoint "\n����� ������� ������� "))
	
	(if (or (= acad_axis "x/2-z" )  (= acad_axis "x/2-z-spesial" ))
		(progn
			; ������� ����-���, ��� �������� ������ ��� ��������� X/2-Z
			(setq _X (nth 1 _pt))
			(setq _Y (car _pt))
			(setq _Y (* -1 _Y))
			(setq _pt (list _X _Y 0) )
		)
	)
	(setq _font_size (get_font_size))
	(setq cnt (LENGTH list_of_coord))
	(setq myTable (vla-AddTable 
                    _model_space
                    (vlax-3d-point _pt)
                    (+ 2 cnt)
                    3
                    0.7
                    (+ (* _font_size 2) 8)
					))
	(vla-setText mytable 0 0 title)
	(vla-setText mytable 1 0 "� �����")
	(vla-setText mytable 1 1 "�")
	(if (or (= acad_axis "x/2-z" )  (= acad_axis "x/2-z-spesial" ))
		(vla-setText mytable 1 2 "Z")
		(vla-setText mytable 1 2 "Y")
	)
	
	(setq _n  0)
	
	(foreach _tmp_coord list_of_coord
		(setq _X (car _tmp_coord))
		(if (= acad_axis "x/2-z" )
			(setq _X (*  2 (round _X 3 )))
		)
		(setq _Y (nth 1 _tmp_coord))
		(setq _X (rtos _X 2 3 ))
		(setq _Y (rtos _Y 2 3 ))
		
		(vla-setText mytable (+ 2 _n) 0 index )
		(vla-setText mytable (+ 2 _n) 1 _X)
		(vla-setText mytable (+ 2 _n) 2 _Y)
		(setq _n (1+ _n ))
		(setq index (+ index 1))
	)
)


;###################################################################################
; ������� ������ � G -������	(�����)
; �������������� � ������


; ����� ��� ������� �� �������(!), ��� �������� �� �����
; FIXME: ���������� ���
; � �����, ��������, ��� ��� ���� �� ������%)

(defun get_part(str _from / _result)
	(setq str (substr str _from))
	(if (= (strlen str) 0)
		(setq _result "000")
		(progn
			(if (= (strlen str) 1)
				(setq _result (strcat str "00"))
				(progn
					(if (= (strlen str) 2)
						(setq _result (strcat str "0"))
						(if  (= (strlen str) 3)
							(setq _result str)
							(if (> (strlen str) 3)
									(setq _result (substr str 1 3))
							)
						)
					)
					)
				)
			)
		)
	)
  
(defun coord_to_string( n_t / _result _res part) ; �������������� ����� � ������
	; ������: 	89.09756 => "89097"
	(if (equal n_t 0.0 0.00001)
			(setq n_t 0)
	)
	(if (= n_t 0)
		(setq _result "0")
		(progn
			(if (/= (fix n_t) 0)
				(if (> n_t 0)
					(progn
						(setq from (strlen (rtos (fix n_t))))
						(setq from (+ from 2))
						(setq part (get_part (rtos n_t 2 4) from))
						(setq _result (itoa (fix n_t)))
						(if (equal ( - n_t  (fix n_t)) 1.0 0.001)
							(progn
							(setq _result (rtos n_t))
							)

							)
						(setq _result (strcat _result part))
					)
					(progn
						(setq from (strlen (rtos (fix n_t))))
						(setq from (+ from 2))
						(setq part (get_part (rtos n_t 2 4) from))
						(setq _result (itoa (fix n_t)))
						(setq _result (strcat _result part))
					)
				)
			)
			(if (= (fix n_t) 0 )
				(if (> n_t 0)
					(progn
						(setq part (get_part (rtos n_t 2 4) 3))
						(setq _result  part)
					)
					(progn
						(setq part (get_part (rtos n_t 2 4) 4))
						(setq _result (strcat "-" part))
					)
				)
			)
		)
	)
	(setq _res _result)
 )
