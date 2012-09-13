;
;###################################################################################
;	AutoLisp
;	������� ��� ���������� ��������,
; 	� ����� ���������� �������.
;###################################################################################
;	������� ������
;	gerasev.kirill@gmail.com
;	24/05/2012
;###################################################################################
;
(load "C:/gk_autocad/main_module")

(defun c:gk-open-cnc ( / _yp); ������� ����� cnc �� ������� ����� � ��������
	(setq _yp (findfile "��.txt") )
	(command "���" (strcat "gvim \"" _yp  "\"" ))
)


(defun C:gk-line( / _p1 _p1_real)
	; ����� �� ��� � ������������� ������������
	(setq _p1 (getpoint "������� ���������� ������ �����:"))
	(setq _p1_real (list
				(/ (car _p1) 2) 
				(nth 1 _p1) 
				0
	))
	(command "_LINE" _p1_real)
	(princ)
)

(defun C:gk-trim()
	(command "_trim" "")
)

(defun C:gk-chamfer(/ _gk_chamfer	_text	_sys_var)
	; �����, ���������� �� ����������, � ������������ ��������
	;
	(setq _sys_var (mapcar 'getvar '("osmode" "cmdecho")))
	(setvar "osmode" 0)
	(setvar "cmdecho" 0)
	;;;;;;;
	
	(if (/=  GK_CHAMFER  nil)
		(setq _text (strcat "\n������� ������ �����<" (rtos GK_CHAMFER ) ">:" ))
		(setq _text "\n������� ������ �����:")
	)
	(setq _gk_chamfer (getreal _text))
	(if (and (= GK_CHAMFER nil ) (/= _gk_chamfer nil))
		(setq GK_CHAMFER _gk_chamfer)
	)
	(setvar "chamfera" GK_CHAMFER)
	(setvar "chamferb" GK_CHAMFER)
	(command "_.chamfer")

	;;;;;;;
	(mapcar 'setvar '("osmode" "cmdecho") _sys_var)
	(princ)
)


(defun C:gk-fillet(/ _gk_fillet	_text _sys_var)
	; ���������� ��������
	;
	(setq _sys_var (mapcar 'getvar '("osmode" "cmdecho")))
	(setvar "osmode" 0)
	(setvar "cmdecho" 0)
	;;;;;;;
	
	(if (/=  GK_FILLET  nil)
		(setq _text (strcat "\n������� ������<" (rtos GK_FILLET ) ">:" ))
		(setq _text "\n������� ������:")
	)
	(setq _gk_fillet (getreal _text))
	(if (and (= GK_FILLET nil ) (/= _gk_fillet nil))
		(setq GK_FILLET _gk_fillet)
	)
	(setvar "filletrad" GK_FILLET)
	(command "_.fillet" )
	
	;;;;;;;
	(mapcar 'setvar '("osmode" "cmdecho") _sys_var)
	(princ)
)



(defun C:gk-offset( / _ent _ent2 _text _lst_point _long _p1 _sys_var)
	; �������� �������� �� ��� � � �������� ��������� ��������
	;
	(setq _sys_var (mapcar 'getvar '("osmode" "cmdecho")))
	(setvar "osmode" 0)
	(setvar "cmdecho" 0)
	;;;;;;;
	
	(if (/=  GK_LONG nil)
		(setq _text (strcat "\n������� ���������� ��������<" (rtos GK_LONG) ">:" ))
		(setq _text "\n������� ���������� ��������:")
	)
	(setq _long (getreal _text))
	(if (and (/= GK_LONG nil ) (= _long nil))
		(setq _long GK_LONG)
	)
	(if (/= _long nil)
		(progn 
			(setq GK_LONG _long)
			(setq _ent (car (entsel "\n�������� ��������: ")))
			(setq _ent2 (entget _ent))
			(setq _lst_point (from_object_to_coord _ent2 ))
			(setq _lst_point (find_real_coord  _lst_point  "x/2-z"))
			(setq _p1 (getpoint "������� �����������:"))
			(if (> (LENGTH _lst_point) 3)
				(command "�������" GK_LONG _ent  _p1 "")
				(if (= (car (car _lst_point)) ( car (last _lst_point)))
						(command "�������" (/ GK_LONG 2) _ent   _p1 "")
						(command "�������" GK_LONG _ent   _p1 "")
				)
			)
		)
	)
	
	;;;;;;;
	(mapcar 'setvar '("osmode" "cmdecho") _sys_var)
	(princ)
)
