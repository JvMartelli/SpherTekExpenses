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
import { VeiculosService } from './veiculos.service';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('veiculos')
export class VeiculosController {
  constructor(private veiculosService: VeiculosService) {}

  @Get()
  async listar(@Request() req) {
    return this.veiculosService.listar(req.user.empresa_id);
  }

  @Post()
  async criar(@Body() body: any, @Request() req) {
    return this.veiculosService.criar(req.user.empresa_id, body);
  }

  @Patch(':id')
  async atualizar(@Param('id') id: string, @Body() body: any, @Request() req) {
    return this.veiculosService.atualizar(id, req.user.empresa_id, body);
  }

  @Delete(':id')
  async deletar(@Param('id') id: string, @Request() req) {
    return this.veiculosService.deletar(id, req.user.empresa_id);
  }
}