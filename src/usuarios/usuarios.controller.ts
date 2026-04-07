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
} from '@nestjs/common';
import { UsuariosService } from './usuarios.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('usuarios')
export class UsuariosController {
  constructor(private usuariosService: UsuariosService) {}

  @Get()
  async listar(@Request() req) {
    return this.usuariosService.listar(req.user.empresa_id);
  }

  @Post()
  async criar(@Body() body: any, @Request() req) {
    return this.usuariosService.criar(req.user.empresa_id, body);
  }

  @Patch(':id')
  async atualizar(@Param('id') id: string, @Body() body: any, @Request() req) {
    return this.usuariosService.atualizar(id, req.user.empresa_id, body);
  }

  @Delete(':id')
  async deletar(@Param('id') id: string, @Request() req) {
    return this.usuariosService.deletar(id, req.user.empresa_id);
  }
}