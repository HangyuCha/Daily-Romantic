-- 회원 프로필 테이블.
-- auth.users(Supabase가 관리하는 로그인 계정)와 1:1로 연결된다.
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  nickname text,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- RLS: 본인 프로필만 읽고 수정할 수 있다.
alter table public.profiles enable row level security;

create policy "본인 프로필 조회" on public.profiles
  for select using (auth.uid() = id);

create policy "본인 프로필 수정" on public.profiles
  for update using (auth.uid() = id);

-- 소셜 로그인으로 처음 가입하면 프로필 행을 자동으로 만든다.
create function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, nickname, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'name', new.raw_user_meta_data ->> 'nickname'),
    new.raw_user_meta_data ->> 'avatar_url'
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
