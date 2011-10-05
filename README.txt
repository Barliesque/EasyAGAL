

EasyAGAL


CHANGE LOG --------------

Revision: 34 - 4.Oct.2011 (Google Code)
- Replaced Blend.softLight() with a formula that is a perfect match with Photoshop and is *far* more efficient
- setFragmentOpcode() and setVertexOpcode() now allow appending.  Instruction counting still not added.
- Retested all blend modes.  Minor updates to avoid possible "two constant parameters" error.
- Removed unsupported facility to select components of a SAMPLER register

Revision: 33 - 4.Oct.2011 (Google Code)
- Fixed bugs in Blend.softLight() and Blend.hardLight() macros

Revision: 32 - 3.Oct.2011 (Google Code)
- Updated AGALMiniAssembler.as to current version!!!
- Removed verboseDebug as it is no longer an option in AGALMiniAssembler

Revision: 31 - 2.Oct.2011 (Google Code)
- added CONST_byIndex
- opcode and instruction count are available now before calling upload()
- shader upload errors now trigger a dump of the shader code with line numbers
- separated debug options in EasyBase constructor
- added interface IComponent to differentiate single components
- new macro Utils.selectByIndex()
