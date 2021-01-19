with system; use system;
with unchecked_conversion;
with text_io; use text_io;

  --==========================================================
  -- corps du paquetage (A ne modifier qu'avec discernement!)
  --==========================================================
  
package body p_esiut is
  
package REEL_IO is new TEXT_IO.FLOAT_IO(FLOAT);
  
--function IMAGE (LE_REEL : in FLOAT) return STRING is

--  S : STRING(1..FLOAT'digits+4) := (others => '0');
--  L : natural := S'length;
--  I : natural := L;
--  
--  begin
--    REEL_IO.PUT(S(1..L),LE_REEL,EXP=>0); 
--    while S(I) = '0'loop
--      I := I - 1;
--    end loop;
--    if S(I) = '.' then I := I + 1; end if;
--    return S(1..I);
--  end IMAGE;
  
function IMAGE(LE_REEL : in float) return string is
	--{} =>{résultat = chaîne représentant LE_REEL en format non scientifique}
	-- PRINCIPE : écrire LE_REEL dans une chaîne de longueur suffisante pour stocker float'first et float'last
	-- PROBLEME : dès que le nombre saisi a plus de 5 chiffres avant la virgule et une partie décimale
	-- de 2 chiffres significatifs il est dégradé...
	-- SOLUTION ADOPTEE :
	-- * si LE_REEL a plus de 5 chiffres avant la virgule et une partie décimale, 
	--   la chaîne résultat est float'image(r)
	-- * sinon : 
	-- - si abs(LE_REEL) > 1.0, LE_REEL est écrit sans exposant avec une partie décimale de 2 chiffres significatifs
	-- - si abs(LE_REEL) < 1.0, LE_REEL est écrit sous la forme 0.00000xxxx

		s : string(1..46) := (others => ' ');
		k, j, exp, nbchiffres : natural;
		Simage : string(1..12); -- chaine donne par float'image
	begin	
		reel_io.put(s, LE_REEL, aft => 2, exp => 0);
		k := s'last-3; -- 2 chiffres de la partie décimale + virgule
		nbchiffres := 0;
		while s(k) /= ' ' and s(k) /= '-' loop
			k := k-1;
			nbchiffres := nbchiffres+1;
		end loop;

		if nbchiffres > 5 then   	-- Grand nombre, on renvoie l'écriture scientifique
			return float'image(LE_REEL);

		elsif abs(LE_REEL) >= 1.0 or LE_REEL=0.0 then	-- Gestion des cas où le problème ne se pose pas...	
			-- on garde 2 décimales, écriture sans exposant
			reel_io.put(s,LE_REEL,aft =>2,exp => 0); 
			-- élimination des espaces avant le nombre
			k := s'first;
			while k < s'last and then s(k)=' ' loop
				k := k+1;
			end loop;
			-- pour cohérence avec image appliquée à un entier : espace avant les réels positifs
			if LE_REEL > 0.0 then
				return ' ' & s(k..s'last);
			elsif LE_REEL = 0.00 then
				return " 0.00";
			else
				return s(k..s'last);		
			end if;
			
		else 				-- abs(LE_REEL) < 1: on renvoie la chaine 0.0000xxxx
			Simage:=float'image(LE_REEL);

			s(1):= Simage(Simage'first); -- espace ou -
			s(2..3) := "0.";

			exp:= integer'value(Simage(Simage'last-1..Simage'last)); -- valeur de l'exposant
			k := 4+exp-2; -- indice du dernier 0
			s(4..k) := (others => '0'); -- tous les 0 après la virgule 

			s(k+1) := Simage(S'first+1); -- premier chiffre significatif
			s(k+2..k+6) := Simage(S'first+3..S'first+7); -- 5 autres chiffres significatifs

			-- élimination des espaces et 0 inutiles à la fin
			j:=k+6;
			while s(j) = '0' or s(j)=' ' loop
				j := j-1;
			end loop;
			return s(1..j);
			
		end if;		
	end IMAGE;

  	 
function IMAGE (L_ENTIER : in INTEGER) return STRING is
 
begin 
  return INTEGER'IMAGE(L_ENTIER);
end IMAGE;
  
function IMAGE (LE_BOOL : in BOOLEAN) return STRING is
-- NEW - 2019
-- affiche la chaîne "TRUE" ou "FALSE" suivant la valeur de LE_BOOL
begin
	return BOOLEAN'image(LE_BOOL);
end IMAGE;
  	 
procedure ECRIRE (LE_REEL : in FLOAT) is     
begin
  TEXT_IO.PUT(IMAGE(LE_REEL));
end ECRIRE;

procedure ECRIRE_LIGNE (LE_REEL : in FLOAT) is     
begin
  ecrire(le_reel);a_la_ligne;
end ECRIRE_LIGNE;
 	 
procedure ECRIRE (L_ENTIER : in INTEGER) is     
begin
  TEXT_IO.PUT(INTEGER'IMAGE(L_ENTIER));
end ECRIRE;

procedure ECRIRE_LIGNE (L_ENTIER : in INTEGER) is     
begin
  ecrire(l_entier);a_la_ligne;
end ECRIRE_LIGNE;

procedure LIRE(LE_REEL : out FLOAT) is
begin
  loop
    begin
      REEL_IO.GET(LE_REEL);
      TEXT_IO.SKIP_LINE;
      exit;
    exception
      when others => TEXT_IO.PUT_LINE("Ce n'est pas un flottant recommencez");
                     TEXT_IO.SKIP_LINE;
    end;
  end loop;
end LIRE;
  	 
procedure LIRE(L_ENTIER : out INTEGER) is
  S : STRING(1..80);           -- 80 pourrait etre diminue
  L : POSITIVE;
begin
  loop
    begin
      TEXT_IO.GET_LINE(S,L);                -- evite d'instancier INTEGER_IO
      L_ENTIER := INTEGER'VALUE(S(1..L));
      exit;
    exception
      when others => TEXT_IO.PUT_LINE("Ce n'est pas un entier recommencez");
    end;
  end loop;
end LIRE;
  
procedure VIDER_TAMPON is
begin
  TEXT_IO.SKIP_LINE;
end VIDER_TAMPON;
  
procedure LIRE( LA_CHAINE : out STRING) is 
  S : STRING(1..LA_CHAINE'LENGTH + 1) := (others => ' ');
  L : integer range 1..S'LENGTH;
begin
  loop
    begin
      TEXT_IO.GET_LINE(S,L);
      if L >= S'LENGTH then                    -- le > n'est jamais vrai!
        TEXT_IO.SKIP_LINE;
        TEXT_IO.PUT_LINE("saisie trop longue recommencez");
	S:= (others => ' ');
      else
        L := LA_CHAINE'LENGTH;
        -- LA_CHAINE(1..L) := S(1..L);
        LA_CHAINE(LA_CHAINE'First..LA_CHAINE'First+L-1) := S(1..L);
        exit;
      end if;
    exception  -- a titre de precaution
      when others => TEXT_IO.PUT_LINE("saisie non valable recommencez");
    end;
  end loop;
end LIRE;
  
procedure LIRE_TRANCHE( LA_CHAINE : out STRING; LONG : out natural) is
  S : STRING(1..LA_CHAINE'LENGTH + 1);
  L : integer range 1..S'LENGTH;
begin
  loop
    begin
      TEXT_IO.GET_LINE(S,L);
      if L >= S'LENGTH then                     -- le > n'est jamais vrai!
        TEXT_IO.SKIP_LINE;
        TEXT_IO.PUT_LINE("saisie trop longue recommencez");
      else
        -- LA_CHAINE(1..L) := S(1..L);
        LA_CHAINE(LA_CHAINE'First..LA_CHAINE'First+L-1) := S(1..L);
        LONG := L;
        exit;
      end if;
    exception  -- a titre de precaution
      when others => TEXT_IO.PUT_LINE("saisie non valable recommencez");
    end;
  end loop;
end LIRE_TRANCHE;
  
procedure LIRE ( CARAC : out CHARACTER) is
begin
  TEXT_IO.GET(CARAC);
  TEXT_IO.SKIP_LINE;
end LIRE;
  
procedure PAUSE is
begin
  TEXT_IO.PUT("appuyez sur Entree pour continuer");
  TEXT_IO.SKIP_LINE;
end PAUSE;
 
procedure clr_ECRAN is
-- Efface l'ecran 

begin
      TEXT_IO.PUT (ASCII.ESC & "[2J");
      TEXT_IO.PUT (ASCII.ESC & "[" & "1" & ";" & "1" & "f");
end clr_ECRAN;
 
  
package body P_ENUM is
  
function IMAGE (L_ENUM : in T_ENUM) return STRING is
begin
  return T_ENUM'IMAGE(L_ENUM);
end IMAGE;     
  
procedure LIRE (L_ENUM : out T_ENUM) is
  S : STRING (1..T_ENUM'WIDTH + 1);
  L : integer range 1..S'LENGTH;
begin
  loop
    begin
      TEXT_IO.GET_LINE(S,L);
      if L >= S'LENGTH then                        -- le > jamais vrai
        TEXT_IO.SKIP_LINE;
        TEXT_IO.PUT_LINE("saisie trop longue recommencez");
      else 
        L_ENUM := T_ENUM'VALUE(S(1..L));
        exit;
      end if;
    exception  -- quand la valeur de type est non conforme
      when others => TEXT_IO.PUT_LINE("Ce n'est pas dans la liste recommencez");
    end;
  end loop;
end LIRE;
  
procedure ECRIRE (L_ENUM : in T_ENUM) is
begin
  TEXT_IO.PUT(T_ENUM'IMAGE(L_ENUM));
end ECRIRE;
  
procedure ECRIRE_LIGNE(L_ENUM : in T_ENUM) is --***
begin
	ecrire(L_ENUM);
	a_la_ligne;
end;

end P_ENUM;
 

procedure ecrire_acc(a : t_acces) is

function conv is new unchecked_conversion(t_acces,integer);
package int_io is new integer_io(integer); use int_io;
begin
put(item => conv(a), base => 16);
end ecrire_acc;

--*** rajouté par laetitia :
procedure ECRIRE_LIGNE(CARAC : CHARACTER) is
begin
	ecrire(CARAC);
	a_la_ligne;
end;

procedure ECRIRE(LE_BOOL : in boolean) is
begin
	ecrire(Boolean'image(LE_BOOL));
end;

procedure ECRIRE_LIGNE(LE_BOOL : in boolean)is
begin
	ecrire(LE_BOOL);
	a_la_ligne;
end;

procedure LIRE(LE_BOOL : out boolean) is
	rep : string(1..5);
begin
	lire(rep);
	while rep/="FALSE" and rep/="false" and rep/="TRUE " and rep/="true " loop
		ecrire_ligne("Recommencez en tapant true ou false");
		lire(rep);
	end loop;
	if rep="FALSE" or rep="false" then LE_BOOL := false;
	else LE_BOOL := true;
	end if;
end;
end p_esiut;
  
