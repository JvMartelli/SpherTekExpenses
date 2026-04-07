import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  UseGuards,
  Request,
  ForbiddenException,
} from '@nestjs/common';
import { UsuariosService } from './usuarios.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../auth/roles.decorator';

@UseGuards(JwtAuthGuard, RolesGuard)
@Controller('usuarios')
export class UsuariosController {
  constructor(private usuariosService: UsuariosService) {}

  @Get()
  @Roles('administrador')
  async listar(@Request() req) {
    return this.usuariosService.listar(req.user.empresa_id);
  }

  @Post()
  @Roles('administrador')
  async criar(@Body() body: any, @Request() req) {
    if (body.perfil === 'administrador' && req.user.perfil !== 'administrador') {
      throw new ForbiddenException('Apenas administradores podem criar outro administrador');
    }
    return this.usuariosService.criar(req.user.empresa_id, body);
  }

  @Patch(':id')
  @Roles('administrador')
  async atualizar(@Param('id') id: string, @Body() body: any, @Request() req) {
    if (body.perfil === 'administrador' && req.user.perfil !== 'administrador') {
      throw new ForbiddenException('Apenas administradores podem definir perfil administrador');
    }
    return this.usuariosService.atualizar(id, req.user.empresa_id, body);
  }

  @Delete(':id')
  @Roles('administrador')
  async deletar(@Param('id') id: string, @Request() req) {
    return this.usuariosService.deletar(id, req.user.empresa_id);
  }
}