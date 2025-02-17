submodule (pathlib) impure_pathlib

implicit none (type, external)

contains

module procedure pathlib_unlink
call unlink(self%path_str)
end procedure pathlib_unlink

module procedure unlink
integer :: u

open(newunit=u, file=path, status='old')
close(u, status='delete')
end procedure unlink


module procedure pathlib_resolve
pathlib_resolve%path_str = resolve(self%path_str)
end procedure pathlib_resolve

module procedure resolve
resolve = canonical(expanduser(path))
end procedure resolve


module procedure pathlib_same_file
pathlib_same_file = same_file(self%path_str, other%path_str)
end procedure pathlib_same_file

module procedure same_file
same_file = resolve(path1) == resolve(path2)
end procedure same_file


module procedure pathlib_is_file
pathlib_is_file = is_file(self%path_str)
end procedure pathlib_is_file

module procedure is_file
inquire(file=expanduser(path), exist=is_file)
if(is_file .and. is_dir(path)) is_file = .false.
end procedure is_file


module procedure pathlib_is_dir
pathlib_is_dir = is_dir(self%path_str)
end procedure pathlib_is_dir

module procedure pathlib_size_bytes
pathlib_size_bytes = size_bytes(self%path_str)
end procedure pathlib_size_bytes

module procedure pathlib_is_exe
pathlib_is_exe = is_exe(self%path_str)
end procedure pathlib_is_exe

module procedure pathlib_mkdir
call mkdir(self%path_str)
end procedure pathlib_mkdir

module procedure pathlib_copy_file
call copy_file(self%path_str, dest, overwrite)
end procedure pathlib_copy_file


module procedure pathlib_expanduser
pathlib_expanduser%path_str = as_posix(expanduser(self%path_str))
end procedure pathlib_expanduser


module procedure expanduser
character(:), allocatable :: homedir

expanduser = trim(adjustl(path))

if (len(expanduser) < 1) return
if(expanduser(1:1) /= '~') return

homedir = home()
if (len_trim(homedir) == 0) return

if (len_trim(expanduser) < 2) then
  !! ~ alone
  expanduser = homedir
else
  !! ~/...
  expanduser = homedir // expanduser(2:)
endif

end procedure expanduser


module procedure pathlib_write_text
call write_text(self%path_str, text)
end procedure pathlib_write_text


module procedure write_text

integer :: u

open(newunit=u, file=filename, status='unknown', action='write')
write(u,'(A)') text
close(u)

end procedure write_text


module procedure pathlib_read_text
pathlib_read_text = read_text(self%path_str, max_length)
end procedure pathlib_read_text


module procedure read_text

integer :: L

L = 16384
if(present(max_length)) L = max_length

block
integer :: u
character(L) :: buf

open(newunit=u, file=filename, status='old', action='read')
read(u,'(A)') buf
close(u)

read_text = trim(buf)
end block

end procedure read_text




end submodule impure_pathlib
