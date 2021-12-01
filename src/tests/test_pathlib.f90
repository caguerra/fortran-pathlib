program pathlib_test

use, intrinsic :: iso_fortran_env, only : stderr=>error_unit
use pathlib, only : mkdir, expanduser, is_absolute, make_absolute, directory_exists, &
file_name, parent, stem, suffix

implicit none (type, external)

call test_manip()

call test_expanduser_absolute()

call test_directory_exists()


contains


subroutine test_manip()

if (stem("hi.a.b") /= "hi.a") error stop "stem failed"
if (stem(stem("hi.a.b")) /= "hi") error stop "stem nest failed"
if (stem("hi") /= "hi") error stop "stem idempotent failed"

if (parent("a/b/c") /= "a/b") error stop "parent failed"
if (parent(parent("a/b/c")) /= "a") error stop "parent nest failed"
if (parent("a") /= ".") error stop "parent idempotent failed"

if (file_name("a/b/c") /= "c") error stop "file_name failed"
if (file_name("c") /= "c") error stop "file_name idempotent failed"

if (suffix("hi.a.b") /= ".b") error stop "suffix failed"
if (suffix(suffix("hi.a.b")) /= "") error stop "suffix nest failed"
if (suffix("hi") /= "") error stop "suffix idempotent failed"

end subroutine test_manip


subroutine test_directory_exists()

integer :: i

if(.not.(directory_exists('.'))) error stop "did not detect '.' as directory"

open(newunit=i, file='test-pathlib.h5', status='replace')
close(i)
if((directory_exists('test-pathlib.h5'))) error stop "detected file as directory"
call unlink('test-pathlib.h5')

print *," OK: pathlib: directory_exists"
end subroutine test_directory_exists


subroutine test_expanduser_absolute()

character(:), allocatable:: fn
character(16) :: fn2

logical :: is_unix

fn = expanduser("~")
is_unix = fn(1:1) == "/"

if (is_absolute("")) error stop "blank is not absolute"

if (is_unix) then
  if (.not.is_absolute("/")) error stop "is_absolute('/') on Unix should be true"
  if (is_absolute("c:/")) error stop "is_absolute('c:/') on Unix should be false"

  fn2 = make_absolute("rel", "/foo")
  if (fn2 /= "/foo/rel") error stop "did not make_absolute Unix /foo/rel, got: " // fn2
else
  if (.not.is_absolute("J:/")) error stop "is_absolute('J:/') on Windows should be true"
  if (.not.is_absolute("j:/")) error stop "is_absolute('j:/') on Windows should be true"
  if (is_absolute("/")) error stop "is_absolute('/') on Windows should be false"

  fn2 = make_absolute("rel", "j:/foo")
  if (fn2 /= "j:/foo/rel") error stop "did not make_absolute Windows j:/foo/rel, got: " // fn2
endif

print *, "OK: pathlib: expanduser,is_absolute"

end subroutine test_expanduser_absolute


subroutine unlink(path)
character(*), intent(in) :: path
integer :: i
logical :: e

inquire(file=path, exist=e)
if (.not.e) return

open(newunit=i, file=path, status='old')
close(i, status='delete')
end subroutine unlink

end program