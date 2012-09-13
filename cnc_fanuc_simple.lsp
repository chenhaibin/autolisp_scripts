;
;###################################################################################
;	AutoLisp
;	��������� �������������� ��������� � ������� � ������������ � "�������"
;		* ����� � acad ��������,
;		* ����� � ��������� �����,
;		* ����� � G-�����.
;###################################################################################
;	(��� ��������� ������� � �������� ��������� X-Z)
;	������� ������
;	gerasev.kirill@gmail.com
;	14/04/2012
;###################################################################################
;
;	��� ���� � ��������� ������ ���������� �� "T-" (����.)
;
;###################################################################################
; �������� ������ � ���������������� ���������

(load "c:/gk_autocad/main_module")


;###################################################################################
; �������� �������
;


(defun C:GK-CNC-PREF()
	;FiXME:		�������� ������� ��������� ����������.
	(princ)
)

(defun C:GK-CNC-POLY( / _lst_point	_sys_var)
	;  
	(setq _sys_var (mapcar 'getvar '("osmode" "cmdecho")))
	(setvar "osmode" 0)
	(setvar "cmdecho" 0)
	;;;;;;;
	
	(setq GK_COLOR 5 )
	(setq ent (car (entsel "\n�������� ���������: ")))
	(setq ent2 (entget ent))
	(setq _lst_point (from_object_to_coord ent2 ))
	(setq  _lst_point (find_real_coord _lst_point "x-z"))
	
	(if (> (nth 1 (car _lst_point))	(nth 1 (last _lst_point)))
		(setq GK_ORDER "right")
		(setq GK_ORDER "left")  
	)
  
	(draw_point_and_text _lst_point "x-z" 1)
	(setq answ (getstring "\n������� �������� ������� �����? <�/�>"))
	(if ( OR ( = answ "�" ) ( = answ "�" ) )
			(progn
				(command "��������"  1)
				(setq _lst_point (revers_order_of_coord _lst_point))
				(draw_point_and_text _lst_point  "x-z" 1)
				(setq GK_LIST_OF_COORD _lst_point)
			)
		)
	(setq GK_ABSOLUTE 1)
	(print_to_table _lst_point "���������� ��������" "x-z" 1)
	
	;;;;;;;
	(mapcar 'setvar '("osmode" "cmdecho") sys_var)
	(princ)
)


(defun C:GK-CNC-MULTI-POLY( / ent _lst_point  _tmp _tmp_print	index)
	(setq GK_COLOR 5 )
	(setq _lst_point NIL)
	(setq _tmp_print NIL)
	(setq _G_code NIL)
	(setq index 1)
	(while (/= (setq ent (car (entsel "\n�������� ������� (����� ���� ���������): ")))	NIL)
		(setq ent2 (entget ent))
		(setq _tmp (from_object_to_coord ent2 ))
		(setq _tmp (draw_all _tmp index "x-z"))
		(setq _tmp (last _tmp))
		(setq _tmp_print (append _tmp_print _tmp))
		(setq index (+ index (LENGTH _tmp)))
	)
	
	;;;;;;;
	(print_to_table _tmp_print "���������� ��������" "x-z" 1) 
	(princ)
)

(defun c:GK-CNC-CONVERT-TABLE (/ obj _i _kord)
	(setq GK_COLOR 5 )
	(vl-load-com)
	(if (setq obj (car (entsel)))
		(progn
			(setq obj (vlax-ename->vla-object obj))
			(if (= (vla-get-ObjectName obj) "AcDbTable")
				(progn	;FiXME	�� �������� � Bricscad (12 ������ ��� Linux)
					(setq _i 2)
					(setq _kord nil)
					(while (< _i (vla-get-rows obj))
						(setq _x (atof (vla-GetText obj _i  1)))
						(setq _z (atof (vla-GetText obj _i 2)))
						(setq _kord (append _kord  (list (list _x _z) )))
						(setq _i (+ _i 1))
					)
				)
			)
		)
	)
  (setq _kord (mk_difference _kord))
  (print_to_table _kord   "������������� ��������"    "x-z"  (atoi (vla-GetText obj 2 0)) )
)

(defun C:GK-CNC-MAKE-CHART(/ _layers _T_layers _T _lay _weigth 	_w   _undo_tmp  _sys_var _material  _p1 _p2 _info)
	; 	���������� ����� "�� ������" ������������ ����������� �� ����� 
	;	"���������"+"������"+"�-..."
	;	��� ��������� ����� ����������� � ���� �� ����.
	;	!!!!!!!!!
	;	����������� ������� ���� "�� ������ (�����)"

	(setq GK_COLOR 5 )
	(vla-startundomark
		(setq _undo_tmp (vla-get-activedocument (vlax-get-acad-object)))
    	) ; ������ ����������� ������
	(setq _sys_var (mapcar 'getvar '("osmode" "cmdecho")))
	(setvar "osmode" 0)
	(setvar "cmdecho" 0)
	;;;;;
	(command "_color" GK_COLOR)
	(setq _layers (get_layers_names))
	(setq _T_layers (is_T _layers))
	(setq _weigth nil)
	(setq _tmp_list nil)
	(foreach _T _T_layers
		(setq _tmp_list (append _tmp_list  
					(list  
					(atoi (substr _T  3 3))
					)
					))
	
	)
	(setq _tmp_list (sort_int _tmp_list))
	(setq _T_layers nil)
	(foreach _T _tmp_list
		(setq _T_layers (append _T_layers  
					(list 
					(strcat "T-" (itoa _T))
					)
					))	
	)
	
	(foreach _T _T_layers
		(command "_LAYER" "_M" (strcat "�� ������ (" _T  ")") "")
		(command "_LAYER" "_S" "0" "")
		(command "_LAYER" "_OFF" (strcat "�� ������ (" _T ")") "")
	)
	
	(setq _layers (get_layers_names))
	(foreach _T 		_T_layers
		(foreach  _lay 	_layers
			(command "_LAYER" "_OFF" _lay "")
		)
		(command "_LAYER" "_ON" "������" "")
		(command "_LAYER" "_ON" "���������" "")
		(command "_LAYER" "_ON" _T   "")
		(copy_to_layer (strcat "�� ������ (" _T ")") 0)	
	)

	(foreach  _lay 	_layers
		(command "_LAYER" "_OFF" _lay "")
	)
	(command "_LAYER" "_M" "�� ������ (�����)" "")
	(command "_LAYER" "_M" (strcat "�� ������ (" (car _T_layers) ")")  "")
	
	; 	���������� �����
	(setq _info (get_all_info))
	; 1 ���
	(command "_text" (list 87.5 51.8)  0  (get_date))
	(command "_text" (list -6 51.8)  0  (strcat (car _info) " " (nth 1 _info)))
	
	; 2 ���
	(command "_text" (list -4.8 47.6 0 )  0  "C�����")
	(command "_text" (list -47 47.6 0 )  0  (nth 2 _info))
	; 	����� ���������� �����
	
	(command "_color" "_BYLAYER")
	(command "_ddptype")
	
	;;;;;;
	(mapcar 'setvar '("osmode" "cmdecho") _sys_var)
	(vla-endundomark _undo_tmp) ; ����� ������� 
)
