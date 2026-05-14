#Requires AutoHotkey v2.0

#SingleInstance Force

TraySetIcon(A_ScriptDir "\Icons\Shorthand_v2.ico")

/*
A - action
B - able, ible
C - cise, ence, erence
G - ing, thing
H - ight
M - ment
mT - mission
N - ness
S - ous
T - tion, sion
V - ive
VN - iveness
X - trans, cross
Y - ity, ary
Z - ization

t= - test
_ - under
; - semi
, - com, comm, con
/ - lean or slash
\ - back
- - less
-N - lessness
+ - ful
+N - fulness
* - multi
8 - ate

*/

; These should only affect the hotstrings in this file.
; Make them all case-sensitive. Use space as the only trigger character.
#Hotstring C Z
#Hotstring EndChars `s

; WARNING: You have to define longer hotstrings before shorter ones.
; Otherwise AHK will prioritize expanding the shorter one since defined first.
::thought+::thoughtful
::thought-::thoughtless
::,trastG::constrasting
::XportaT::transportation
::sud!bB2::should not be able to
::thank+y::thankfully
::,trast::contrast
::XformT::transformation
::XportG::transporting
::_takeG::undertaking
::creatG::creating
::sudbB2::should be able to
::thank+::thankful
::u4tn8y::unfontunately
::wudbB2::would be able to
::*tude::multitude
::,curC::concurence
::,fluC::confluence
::,venT::convention
::4tn8y::fortunately
::Xform::Send("transform")
::_st&G::understanding
::care+::careful
::care-::careless
::creaT::creation
::naTlZ::nationalize
::retrA::retraction
::sud!h::should not have
::sudth::shouldn't
::wudl2::would like to
::*ple::multiple
::*ply::multiply
::4tn8::fortunate
::Inet::internet
::Xl8T::translation
::^t?G::overthinking
::_st&::understand
::ampD::amplitude
::cudh::could have
::cudt::could not
::flH-::flightless
::gr8+::grateful
::graD::gratitude
::i18n::internationalization
::iv!b::I haven't been
::lHnG::lightning
::naTl::national
::st&G::standing
::sthe::something else
::sud!::should not
::sudb::should be
::sudh::should have
::sudt::shouldn't
::t?+N::thoughtfulness
::tyr!::they're not
::varB::variable
::wer!::we're not
::wud!::would not
::wudh::would have
::wudt::wouldn't
::,qC::consequence
::,qV::consequtive
::,t=::contest
::4tn::fortune
::IAG::interacting
::INl::international
::Xl8::translate
::afr::away from
::alD::altitude
::apD::aptitude
::bB2::be able to
::bco::because of
::blH::blight
::c/G::cleaning
::c/d::cleaned
::c/r::cleaner
::c/s::cleans
::cud::could
::edB::edible
::flH::flight
::frA::fraction
::gG2::going to
::hv!::have not
::hvt::haven't
::im!::I'm not
::inA::inaction
::iv!::I haven't
::ivb::I've been
::lHG::lighting
::nGe::nothing else
::naT::nation
::noT::notion
::qne::whenever
::qoe::whoever
::qre::wherever
::qte::whatever
::qwe::however
::qwm::how many
::reA::reaction
::s1e::someone else
::sGe::something else
::sHG::sighting
::sth::something
::sud::should
::t=M::testament
::t?+::thoughtful
::t?G::thinking
::trA::traction
::tyr::they're
::ulb::you'll be
::un-::unless
::ur!::you're not
::uvb::you've been
::wer::we're
::wud::would
:?:'t::'t ; lets normal contractions work
::,C::concise
::.-::pointless
::/G::leaning
::2d::today
::2m::tomorrow
::4m::for me
::4u::for you
::4v::forever
::?B::questionable
::?G::questioning
::?d::questioned
::?s::questions
::AA::A
::IA::interaction
::XG::crossing
::XT::transition
::a1::anyone
::aD::attitude
::aG::anything
::aa::and
::ab::about
::af::after
::b+::better
::b4::before
::bG::being
::bc::because
::bn::been
::c!::cannot
::c/::clean
::ct::can't
::eG::everything
::fA::faction
::fr::from
::gG::going
::hH::height
::hv::have
::im::I'm
::iv::I've
::lH::light
::m+::many
::n1::no one
::nG::nothing
::nH::night
::ov::over
::qh::which
::qn::when
::qo::who
::qr::where
::qt::what
::qw::how
::rH::right
::s1::someone
::sG::something
::sH::sight
::sb::somebody
::sd::someday
::st::sometime
::t4::therefore
::t=::test
::t?::think
::tm::them
::tn::than
::tr::there
::ts::this
::tt::that
::tw::toward
::ty::they
::ul::you'll
::un::under
::ur::you're
::ut::until
::uv::you've
::w2::want to
::xT::exception
::!::not
::+::more
::-::less
::?::question
::A::action
::B::able
::G::thing
::^::over
::_::under
::b::be
::c::can
::d::do
::e::each
::f::for
::g::get
::h::have
::i::is
::j::just
::k::know
::l::like
::m::me
::n::and
::o::of
::p::people
::q::quite
::r::are
::s::some
::t::the
::u::you
::v::very
::w::with
::x::except
::y::why
::z::zero

; END

RemoveToolTip() => ToolTip()

; Terminate this keystroke handler. End this mode.
LControl & Escape:: {
	ToolTip("Shorthand mode OFF")
	Suspend(true)
	SetTimer(RemoveToolTip, -2000)
	Sleep(2000)
	ExitApp
}

